extends Control

onready var grid = $HBoxContainer/BoardContainer/GridContainer.get_children()
onready var numbers = $HBoxContainer/SettingsContainer/CenterContainer/Numbers.get_children()
var selected_number = 1


func _ready():
	# Connects grid buttons
	for i in grid.size():
		var row = int(i / 9)
		var col = i % 9
		grid[i].connect("button_down", self, "_on_grid_button_pressed", [row, col])
	
	# Connects number buttons
	for i in numbers.size():
		numbers[i].connect("button_down", self, "_on_number_button_pressed", [i])


func _on_Clear_pressed():
	for child in grid:
		child.text = ""


func _on_grid_button_pressed(row, col):
	if Input.is_mouse_button_pressed(2):
		grid[row * 9 + col].text = ""
	else:
		grid[row * 9 + col].text = str(selected_number)


func _on_number_button_pressed(i):
	selected_number = i + 1

	for child in numbers:
		child.pressed = false


# Checks whether there are repeated numbers in the grid
# caused by changes in [row, col]
func _is_board_valid_after_changes(row, col):
	var row_numbers = [0,0,0,0,0,0,0,0,0,0]
	var col_numbers = [0,0,0,0,0,0,0,0,0,0]
	var grid_numbers = [0,0,0,0,0,0,0,0,0,0]
	
	# Index to the top-left corner of the 3x3 grid
	var grid_offset = int(row / 3) * 3 * 9 + int(col / 3) * 3

	for i in 9:
		row_numbers[int(grid[row * 9 + i].text)] += 1
		col_numbers[int(grid[i * 9 + col].text)] += 1
		grid_numbers[int(grid[grid_offset + int(i / 3) * 9 + (i % 3)].text)] += 1

	for i in 9:
		if row_numbers[i + 1] > 1: return false
		if col_numbers[i + 1] > 1: return false
		if grid_numbers[i + 1] > 1: return false

	return true


func _is_board_valid():
	for i in 9:
		if not _is_board_valid_after_changes(i, i):
			return false

	return true


func _on_Solve_pressed():
	if not _is_board_valid():
		print("Invalid board")
