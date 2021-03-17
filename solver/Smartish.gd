extends "Solver.gd"



func solve():
	._solve()

	if not _is_board_valid():
		return false

	return _recurse()

# Returns the index of the first set bit in 'a',
# -1 otherwise
func _single_set_bit(a):
	for i in range(1, 10):
		if a & (1 << i):
			return i


# Counts how many bits are set in the given number
func _count_bits(a):
	var ret = 0

	while a:
		ret += 1
		a &= a - 1

	return ret


# Solves the sudoku using backtracking with some minor optimization
# Roughly 5 times faster than normal backtracking, but still a bit
# too slow for hard puzzles
func _recurse(depth=0):
	if depth >= grid.size(): return true

	var i = -1
	var min_cnt = 999
	var modified = []

	# Finding the cell with fewest available values.
	# Also sets all cells which have only one available value
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

	# Normal backtracking
	if i == -1: return true
	modified.append(i)
	var valid = _valid_numbers(i)

	for j in range(1, 10):
		if valid & (1 << j):
			grid[i] = j
			if _recurse(depth + 1): return true

	for m in modified: grid[m] = 0
	return false
