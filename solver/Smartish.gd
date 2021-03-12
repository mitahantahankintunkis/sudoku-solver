extends "Solver.gd"

#var choices = []

func solve():
	._solve()

	if not _is_board_valid():
		return false
#
#	for i in grid.size():
#		choices.append(0)

	return _recurse()

# Returns the index of a bit if it is the only set bit in 'a',
# -1 otherwise
func _single_set_bit(a):
	var bit = 0
	for i in range(1, 10):
		if a & (1 << i):
			if bit != 0: return -1
			bit = i

	return bit


#func _set_value(i, a):
#	grid[i] = a
#
#	var row = int(i / 9)
#	var col = i % 9
#	var quad_offset = int(row / 3) * 3 * 9 + int(col / 3) * 3
#	var mask = 0b1111111111 ^ (1 << a)
#
#	for j in 9:
#		choices[row * 9 + j] &= mask
#		choices[j * 9 + col] &= mask
#		choices[quad_offset + int(j / 3) * 9 + (j % 3)] &= mask
#
#
#func _unset_value(i):
#	grid[i] = 0
#
#	var row = int(i / 9)
#	var col = i % 9
#	var quad_offset = int(row / 3) * 3 * 9 + int(col / 3) * 3
#	var mask = 0b1111111111 ^ (1 << a)
#
#	for j in 9:
#		choices[row * 9 + j] &= mask
#		choices[j * 9 + col] &= mask
#		choices[quad_offset + int(j / 3) * 9 + (j % 3)] &= mask

func _count_bits(a):
	var ret = 0

	while a:
		ret += 1
		a &= a - 1

	return ret


# Solves the sudoku using backtracking with some minor optimization
func _recurse(depth=0):
	if depth >= grid.size(): return true

	var i = -1
	var min_cnt = 999
	var modified = []

	_update_matrix()
	for j in grid.size():
		if grid[j] != 0: continue
		var v = matrix[j]
		var cnt = _count_bits(v)

		if cnt == 1:
			if _valid_numbers(j) == 0:
				for m in modified: grid[m] = 0
				return false

			grid[j] = _single_set_bit(v)
			modified.append(j)

		elif min_cnt > cnt:
			min_cnt = cnt
			i = j

#	for j in grid.size():
#		for value in range(1, 10):
#			if not (mask[j] & (1 << value)): continue
#			var row = int(j / 9)
#			var col = j % 9
#			var sec = int(j / 9)
#			var row_cnt = 0
#			var col_cnt = 0
#			var sec_cnt = 0
#			var row_i = 0
#
#			for k in 9:
#				if grid[row * 9 + k] == value:
#					row_cnt += 1
#					row_i = row * 9 + k
#
#			if row_cnt == 1:
#				grid[row_i] = value
				
#	for row in 9:
#		for a in range(1, 10):
#			if not (row_masks & (1 << a)): continue
#
#			var only = false
#			for col in 9:
#				if grid[row * 9 + col] == a:
#					if only:
#						only = false
#						break
#
#						only = true
		
#	for j in grid.size():
#		var row = int(i / 9)
#		var col = i % 9
#		var sec = int(row / 3) * 3 + int(col / 3)
#
#		matrix[i] = row_masks[row] & col_masks[col] & sec_masks[sec]

	if i == -1: return true
	modified.append(i)
	var valid = _valid_numbers(i)

	for j in range(1, 10):
		if valid & (1 << j):
			grid[i] = j
			if _recurse(depth + 1): return true

	for m in modified: grid[m] = 0
	return false
