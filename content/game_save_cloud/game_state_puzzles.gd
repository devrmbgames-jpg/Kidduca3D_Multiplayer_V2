extends Reference

var puzzles := []

func push_puzzle(puzzle: String) :
	if not puzzles.has(puzzle):
		puzzles.append(puzzle)

func has_puzzle(puzzle: String) -> bool :
	return puzzles.has(puzzle)

func to_array() -> Array :
	return puzzles

func from_array(from_list: Array) -> void :
	for puzzle in from_list :
		if not puzzles.has(puzzle) :
			puzzles.append(puzzle)
