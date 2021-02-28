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


func _ready():
	# Initializes grid
	for y in grid_buttons.size():
		grid.append(0)

	grid = [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 3, 0, 8, 0, 0, 0, 0, 2, 5, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 5, 0, 0, 7, 0, 0, 0, 0, 0, 0, 3, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 7, 0, 0, 0, 0, 9, 0, 0, 6, 0, 2, 0]

	for i in 9:
		row_sets.append([0,0,0,0,0,0,0,0,0,0])
		col_sets.append([0,0,0,0,0,0,0,0,0,0])
		grid_sets.append([0,0,0,0,0,0,0,0,0,0])

	for i in grid.size():
		var row_i = int(i / 9)
		var col_i = i % 9
		var grid_i = int(int(i / 9) / 3) * 3 + int((i % 9) / 3)

		row_sets[row_i][grid[i]] = 1
		col_sets[col_i][grid[i]] = 1
		grid_sets[grid_i][grid[i]] = 1

	# Initializes button colors
	for i in grid_buttons.size():
		button_colors.append(palette["normal"])

	# Connects grid buttons
	for i in grid_buttons.size():
		grid_buttons[i].connect("button_down", self, "_on_grid_button_pressed", [i])
		grid_buttons[i].connect("mouse_entered", self, "_on_grid_button_mouse_enter", [i])
		grid_buttons[i].connect("mouse_exited", self, "_on_grid_button_mouse_exit", [i])


var solving = false
var stack = [0]

func _process(_delta):
	for key in range(1, 10):
		if Input.is_action_pressed(str(key)):
			selected_number = key
			_on_grid_button_mouse_enter(hover_i)
			break
	
	if solving:
		var i = stack.pop_back()
		if i >= grid.size():
			solving = false
			return
		
		if grid[i] > 0:
			stack.push_back(i + 1)
			return
		
		for j in range(1, 10):
			grid[i] = j
			if _is_board_valid_after_changes(i):
				stack.push(i + 1)
		grid[i] = 0


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


func _solve_recursive(i=0):
	if i >= grid_buttons.size():
		return true

	if grid[i] != 0:
		return _solve_recursive(i + 1)

	button_colors[i] = palette["generated"]

	for j in range(1, 10):
		if _update_cell(i, j):
			if _solve_recursive(i + 1):
				return true

	_update_cell(i, 0)
	return false

#		if _is_board_valid_after_changes(i):
#			if _solve_recursive(i + 1):
#				return true

#	grid[i] = 0
#	return false


func _on_Clear_pressed():
	for child in grid_buttons:
		child.text = ""

	for i in grid.size():
		grid[i] = 0


func _on_Solve_pressed():
	for i in grid.size():
		if button_colors[i] != palette["normal"]:
			grid[i] = 0

	if not _is_board_valid():
		print("Invalid board")
	else:
		solving = true
		return
		if not _solve_recursive():
			print("Could not solve")

		_update_board()
