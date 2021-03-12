extends Node

var grid = []
onready var buttons = get_node("/root/UI/VBoxContainer/CenterContainer/GridContainer").get_children()
var mask = []
var matrix = []
var row_masks = []
var col_masks = []
var sec_masks = []
#var row_masks = [1022,1022,1022,1022,1022,1022,1022,1022,1022]
#var col_masks = [1022,1022,1022,1022,1022,1022,1022,1022,1022]
#var sec_masks = [1022,1022,1022,1022,1022,1022,1022,1022,1022]

func _ready():
	for button in buttons:
		grid.append(int(button.text))
		mask.append(0)
		matrix.append(0)

	for i in 9:
		row_masks.append(0)
		col_masks.append(0)
		sec_masks.append(0)


# "Virtual" function which updates grid
func _solve():
	for i in buttons.size():
		grid[i] = int(buttons[i].text)


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


func bin(a):
	var r = ""
	while a:
		r = str(a & 1) + r
		a >>= 1
	return r


func _update_matrix():
	for i in row_masks.size():
		row_masks[i] = 0b1111111110
		col_masks[i] = 0b1111111110
		sec_masks[i] = 0b1111111110

	for i in grid.size():
		mask[i] = 0b1111111111 ^ (1 << grid[i])

	for i in grid.size():
		var row = int(i / 9)
		var col = i % 9
		var sec_offset = int((row * 3) / 9) * 27 + ((row * 3) % 9)
		row_masks[row] &= mask[row * 9 + col]
		col_masks[row] &= mask[col * 9 + row]
		sec_masks[row] &= mask[sec_offset + int(col / 3) * 9 + (col % 3)]

	for i in grid.size():
		var row = int(i / 9)
		var col = i % 9
		var sec = int(row / 3) * 3 + int(col / 3)
		matrix[i] = row_masks[row] & col_masks[col] & sec_masks[sec]
