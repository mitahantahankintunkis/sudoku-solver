extends Node

var grid = []
onready var buttons = get_node("/root/UI/VBoxContainer/CenterContainer/GridContainer").get_children()


# "Virtual" function which updates grid
func _solve():
	grid.clear()

	for button in buttons:
		grid.append(int(button.text))
	print(grid)


func _is_board_valid():
	for i in grid.size():
		if grid[i] != 0:
			var cur = grid[i]
			grid[i] = 0
			var valid = _valid_numbers(i)
			grid[i] = cur

			if not (valid & (1 << cur)):
				return false


	return true


# Returns valid numbers for cell 'i'
# Example:
#   Valid:     98  543 1
#   Return:  0b1100111010
func _valid_numbers(i):
	var valid = 0b1111111110
	var row = int(i / 9)
	var col = i % 9
	var quad_offset = int(row / 3) * 3 * 9 + int(col / 3) * 3

	for j in 9:
		valid &= (0b1111111111 ^ (1 << grid[row * 9 + j]))
		valid &= (0b1111111111 ^ (1 << grid[j * 9 + col]))
		valid &= (0b1111111111 ^ (1 << grid[quad_offset + int(j / 3) * 9 + (j % 3)]))

	return valid
