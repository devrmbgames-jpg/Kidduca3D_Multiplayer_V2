extends Reference
#class_name GameStateCharacter

signal unlocked_character(char_id)
var character_list := [0, 1]

func push_character(char_id: int) -> void :
	if not character_list.has(char_id) :
		character_list.append(char_id)
		emit_signal("unlocked_character", char_id)

func has_character(char_id: int) -> bool :
	return character_list.has(char_id)


func to_array() -> Array :
	return character_list

func from_array(from: Array) -> void :
	var new_character := []
	for idx in from:
		if not new_character.has(idx as int) :
			new_character.append(idx as int)
	
	for idx in character_list :
		if not new_character.has(idx as int) :
			new_character.append(idx as int)
	
	character_list = new_character
	
