extends Control

var palette = {
	"normal": Color("000000"),
	"hover": Color("888888"),
	"generated": Color("#118ab2"),
}

onready var grid_buttons = $VBoxContainer/CenterContainer/GridContainer.get_children()
var selected_number = 1
var grid = []
var hover_i = 0
var hover_color = palette["hover"]
var button_colors = []
var row_sets = []
var col_sets = []
var grid_sets = []
var random_order = []
var allowed_values = []

var allowed = []

func _ready():
	# Initializes grid
	for y in grid_buttons.size():
		grid.append(0)

	grid = [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 3, 0, 8, 0, 0, 0, 0, 2, 5, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 5, 0, 0, 7, 0, 0, 0, 0, 0, 0, 3, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 7, 0, 0, 0, 0, 9, 0, 0, 6, 0, 2, 0]

	for i in grid.size():
		allowed.append(0b1111111111)

	for i in 9:
		row_sets.append([0,0,0,0,0,0,0,0,0,0])
		col_sets.append([0,0,0,0,0,0,0,0,0,0])
		grid_sets.append([0,0,0,0,0,0,0,0,0,0])

	for i in grid.size():
		allowed_values.append([false,false,false,false,false,false,false,false,false,false,])

	for i in grid.size():
		random_order.append(i)
		var row_i = int(i / 9)
		var col_i = i % 9
		var grid_i = int(int(i / 9) / 3) * 3 + int((i % 9) / 3)

		row_sets[row_i][grid[i]] = 1
		col_sets[col_i][grid[i]] = 1
		grid_sets[grid_i][grid[i]] = 1

	randomize()
	random_order.shuffle()

	# Initializes button colors
	for i in grid_buttons.size():
		button_colors.append(palette["normal"])

	# Connects grid buttons
	for i in grid_buttons.size():
		grid_buttons[i].connect("button_down", self, "_on_grid_button_pressed", [i])
		grid_buttons[i].connect("mouse_entered", self, "_on_grid_button_mouse_enter", [i])
		grid_buttons[i].connect("mouse_exited", self, "_on_grid_button_mouse_exit", [i])


func _process(_delta):
	for key in range(1, 10):
		if Input.is_action_pressed(str(key)):
			selected_number = key
			_on_grid_button_mouse_enter(hover_i)
			break


func _on_grid_button_pressed(i):
	button_colors[i] = palette["normal"]

	if Input.is_mouse_button_pressed(2):
		grid[i] = 0
	else:
		grid[i] = selected_number
		grid_buttons[i].set("custom_colors/font_color_hover", button_colors[i])
	
	_on_grid_button_mouse_enter(i)
	_update_board()


func _on_grid_button_mouse_enter(i):
	hover_i = i
	if grid[i] != selected_number:
		grid_buttons[i].set("custom_colors/font_color_hover", hover_color)
		grid_buttons[i].text = str(selected_number)


func _on_grid_button_mouse_exit(_i):
	_update_board()


# Updates grid buttons based on grid numbers and colors
func _update_board():
	for i in grid.size():
		if grid[i] != 0:
			grid_buttons[i].text = str(grid[i])
		else:
			grid_buttons[i].text = ""

		grid_buttons[i].set("custom_colors/font_color", button_colors[i])


# Checks whether there are repeated numbers in the grid
# caused by changes in [row, col]
func _is_board_valid_after_changes(i):
	var row = int(i / 9)
	var col = i % 9

	var row_numbers = [0,0,0,0,0,0,0,0,0,0]
	var col_numbers = [0,0,0,0,0,0,0,0,0,0]
	var grid_numbers = [0,0,0,0,0,0,0,0,0,0]

	# Index to the top-left corner of the 3x3 grid
	var grid_offset = (int(row / 3) * 3) * 9 + (int(col / 3) * 3)

	for i in 9:
		row_numbers[grid[row * 9 + i]] += 1
		col_numbers[grid[i * 9 + col]] += 1
		grid_numbers[grid[grid_offset + int(i / 3) * 9 + (i % 3)]] += 1

	for i in 9:
		if row_numbers[i + 1] > 1: return false
		if col_numbers[i + 1] > 1: return false
		if grid_numbers[i + 1] > 1: return false

	return true


func _is_board_valid():
	for i in 9:
		if not _is_board_valid_after_changes(i * 9 + i):
			return false

	return true


func _update_cell(i, value):
	var cur_value = grid[i]
	var row_i = int(i / 9)
	var col_i = i % 9
	var grid_i = int(int(i / 9) / 3) * 3 + int((i % 9) / 3)

	if value != 0:
		if row_sets[row_i][value] > 0: return false
		if col_sets[col_i][value] > 0: return false
		if grid_sets[grid_i][value] > 0: return false

	row_sets[row_i][cur_value] = 0
	col_sets[col_i][cur_value] = 0
	grid_sets[grid_i][cur_value] = 0

	row_sets[row_i][value] = 1
	col_sets[col_i][value] = 1
	grid_sets[grid_i][value] = 1

	grid[i] = value

	return true


func _count_bits(n):
	var ret = 0
	while n:
		n &= n - 1
		ret += 1

	return ret


func _solve_recursive(i=0):
	if i >= grid.size(): return true
	_update_allowed_matrix()
	var changed = [i]

	for j in range(1, 10):
		if allowed[i] & (1 << j):
			grid[i] = j
			if _solve_recursive(i + 1):
				return true

	for j in changed:
		grid[j] = 0

	return false


	# If only one value is allowed in some place
#	for j in allowed.size():
#		if _count_bits(allowed[j]) == 1:
#			for k in range(1, 10):
#				if allowed[j] & (1 << k):
#					grid[j] = k
#					changed.append(j)
#					break

	# If only one value is allowed in some area
#	for i in allowed.size():
#		for n in range(1, 10):
#			for row in 9:
#				for col in 9:

	#var i = random_order[depth]
#	var min_cnt = 9999
#	print(i)
#	for j in grid.size():
#		if grid[j] > 0: continue
#
#		var cnt = allowed_values[j].count(true)
#		if allowed_values[j][0]: cnt -= 1
#		if cnt > 0 and min_cnt > cnt:
#			i = j
#			min_cnt = cnt

#	if grid[i] != 0:
#		return _solve_recursive(depth + 1)
#		if allowed_values[i][j]:
#			grid[i] = j
#
#			_update_allowed_values(i)
#
		#if _is_board_valid_after_changes(i):
#		if _update_cell(i, j):
#			if _solve_recursive(i + 1):
#				return true
#
#	_update_cell(i, 0)
#	return false



func _on_Clear_pressed():
	for child in grid_buttons:
		child.text = ""

	for i in grid.size():
		grid[i] = 0


# Should probably be done with some bit-twiddling
#func _update_allowed_values(i):
#	var row = int(i / 9)
#	var col = i % 9
#	var grid_offset = (int(row / 3) * 3) * 9 + (int(col / 3) * 3)
#
#	for j in 9:
#		allowed_values[i][j] = true
#
#	for j in 9:
#		allowed_values[i][grid[row * 9 + j]] = false
#		allowed_values[i][grid[j * 9 + col]] = false
#		allowed_values[i][grid[grid_offset + int(j / 3) * 9 + (j % 3)]] = false


func _update_allowed_matrix():
#	var allowed = []
	for i in allowed.size():
		allowed[i] = 0b1111111111

	for i in grid.size():
		var row = int(i / 9)
		var col = i % 9
		var grid_offset = (int(row / 3) * 3) * 9 + (int(col / 3) * 3)

		for j in 9:
			allowed[i] &= ~(1 << grid[row * 9 + j])
			allowed[i] &= ~(1 << grid[j * 9 + col])
			allowed[i] &= ~(1 << grid[grid_offset + int(j / 3) * 9 + (j % 3)])

	for row in 9:
		for i in range(1, 10):
			if allowed[row * 9 + 1] & (1 << i):
				prints(row, allowed[row * 9 + 1], i)

	return allowed

#	var matrix = []
#	for used in used_numbers:
#		var allowed = 0
#		for j in range(1, 10):
#			if not j in used:
#				allowed |= 1 << j
#		matrix.append(allowed)

#	return matrix
#	var max_i = 0
#	var max_count = 0
#
#	for i in grid.size():
#		if grid[i] > 0: continue
#
#		var count = used_numbers[i].size()
#		if 0 in used_numbers[i]: count -= 1
#
#		if max_count < count:
#			max_count = count
#			max_i = i

#	prints(0, used_numbers[0])
#	print(30, used_numbers[30])
#	print()
#	prints(max_i, int(max_i / 9), max_i % 9, max_count, used_numbers[max_i])
#	return [max_i, used_numbers[max_i]]


func _on_Solve_pressed():
	for i in grid.size():
		if button_colors[i] != palette["normal"]:
			grid[i] = 0

		if grid[i] == 0:
			button_colors[i] = palette["generated"]

	if not _is_board_valid():
		print("Invalid board")
	else:
#		_update_allowed_matrix()
#		return
		if not _solve_recursive():
			print("Could not solve")

		_update_board()
