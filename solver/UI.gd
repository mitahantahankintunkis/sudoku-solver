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

var allowed = []

func _ready():
	# Initializes grid
	for y in grid_buttons.size():
		grid.append(0)

	grid = [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 3, 0, 8, 0, 0, 0, 0, 2, 5, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 5, 0, 0, 7, 0, 0, 0, 0, 0, 0, 3, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 7, 0, 0, 0, 0, 9, 0, 0, 6, 0, 2, 0]

	for i in grid.size():
		allowed.append(0b1111111110)

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
	for i in grid.size():
		if not _is_board_valid_after_changes(i):
			return false

	return true


func _count_bits(n):
	var ret = 0
	while n:
		n &= n - 1
		ret += 1

	return ret

func _union(a, b):
	return a | b

func _intersect(a, b):
	return a & b

func _difference(a, b):
	return a & (0b1111111111 ^ b)

func _set_bit(a):
	if a == 0: return 0

	var ret = 0
	while not (a & (1 << ret)):
		ret += 1
	
	return ret

func _solve_recursive(depth=0):
	if depth >= grid.size(): return true

	_update_allowed_matrix()
	var i = depth
#	var min_cnt = 0
	for j in allowed.size():
		if grid[j] > 0: continue
		if _count_bits(allowed[j]) == 1:
			i = j
			break
#		if min_cnt < cnt:
#			min_cnt = cnt
#			i = j

	var changed = [i]

	if grid[i] > 0: return _solve_recursive(depth + 1)

#	for j in allowed.size():
#		if j == i or grid[j] > 0: continue
#
#		if _count_bits(allowed[j]) == 1:
#			changed.append(j)
#			grid[j] = _set_bit(allowed[j])
#			button_colors[j] = Color.aquamarine
#			_update_allowed_matrix()

#	for j in allowed.size():
#		if j == i or grid[j] > 0: continue
#
#		var row = int(j / 9)
#		var col = j % 9
#		var grid_offset = (int(row / 3) * 3) * 9 + (int(col / 3) * 3)
#
#		for k in 9:
			

	for j in range(1, 10):
		if allowed[i] & (1 << j):
			grid[i] = j
			button_colors[i] = Color(0.05, 0.2, depth / 81.0)

			if _solve_recursive(depth + 1):
				return true

	for j in changed:
		grid[j] = 0
		button_colors[j] = palette["generated"]

	_update_allowed_matrix()

	return false


func _on_Clear_pressed():
	for child in grid_buttons:
		child.text = ""

	for i in grid.size():
		grid[i] = 0


func _update_allowed_matrix():
#	var allowed = []
	for i in allowed.size():
		allowed[i] = 0b1111111110

	for i in grid.size():
		var row = int(i / 9)
		var col = i % 9
		var grid_offset = (int(row / 3) * 3) * 9 + (int(col / 3) * 3)

		for j in 9:
			allowed[i] = _difference(allowed[i], 1 << grid[row * 9 + j])
			allowed[i] = _difference(allowed[i], 1 << grid[j * 9 + col])
			allowed[i] = _difference(allowed[i], 1 << grid[grid_offset + int(j / 3) * 9 + (j % 3)])
#			allowed[i] &= ~(1 << grid[row * 9 + j])
#			allowed[i] &= ~(1 << grid[j * 9 + col])
#			allowed[i] &= ~(1 << grid[grid_offset + int(j / 3) * 9 + (j % 3)])

#	for row in 9:
#		for i in range(1, 10):
#			if allowed[row * 9 + 1] & (1 << i):
#				prints(row, allowed[row * 9 + 1], i)

	return allowed


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
