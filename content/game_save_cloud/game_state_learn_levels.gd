extends Reference
#class_name GameStateReward

var completed_levels := {}


func push_level(level: String, key: String) -> void :
	if completed_levels.has(key):
		if not completed_levels[key].has(level):
			completed_levels[key].append(level)
	else:
		completed_levels[key] = [level]

func get_levels(key: String) -> Array :
	return completed_levels.get(key, [])

func has_level(level: String, key: String) -> bool :
	if completed_levels.has(key):
		if completed_levels[key].has(level):
			return true
	return false


func to_dictionary() -> Dictionary :
	return completed_levels

func from_dictionary(dict: Dictionary) :
	for key in dict :
		if not completed_levels.has(key):
			completed_levels[key] = dict[key]
		else:
			for level in dict[key]:
				if not completed_levels[key].has(level):
					completed_levels[key].append(level)
