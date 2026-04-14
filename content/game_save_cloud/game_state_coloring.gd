extends Reference
#class_name GameStateColoring

var coloring_list := []

func push_coloring(coloring: String) -> void :
	if not coloring_list.has(coloring) :
		coloring_list.append(coloring)

func has_coloring(coloring: String) -> bool :
	return coloring_list.has(coloring)


func to_array() -> Array :
	return coloring_list

func from_array(from_list: Array) -> void :
	for coloring in from_list :
		if not coloring_list.has(coloring) :
			coloring_list.append(coloring)
