extends "Solver.gd"


func solve():
	._solve()

	if not _is_board_valid():
		return false

	return _recurse()


# Solves the sudoku using backtracking without any optimization.
# Is too slow with GDScript, takes around 70s for harder puzzles
func _recurse(depth=0):
	if depth >= grid.size(): return true
	if grid[depth] != 0: return _recurse(depth + 1)

	var valid = _valid_numbers(depth)

	for i in range(1, 10):
		if valid & (1 << i):
			grid[depth] = i
			if _recurse(depth + 1): return true

	grid[depth] = 0
	return false
