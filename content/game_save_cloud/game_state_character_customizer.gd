extends Reference
#class_name GameStateCharacterCustomizer

const RewardItemsConst := preload("res://content/ui/reward_items/reward_items_const.gd")

var _custom_template := {
	str(RewardItemsConst.TYPE_ITEM.HATS) : "",
	str(RewardItemsConst.TYPE_ITEM.SKIRTS) : "",
	str(RewardItemsConst.TYPE_ITEM.CAPES) : "",
	str(RewardItemsConst.TYPE_ITEM.BOWS) : "",
	str(RewardItemsConst.TYPE_ITEM.GLASSES) : "",
	str(RewardItemsConst.TYPE_ITEM.AMULETS) : "",
	str(RewardItemsConst.TYPE_ITEM.BRASLETES) : ""
}

var characters_custom := {}

func put_on_reward_item(character: int, item: String) -> void :
	
	var char_str : String = str(character)
	var type_item_str : String = str(RewardItemsConst.get_type_item(item))
	if characters_custom.has(char_str) :
		characters_custom[char_str][type_item_str] = item
	else:
		characters_custom[char_str] = _custom_template.duplicate()
		characters_custom[char_str][type_item_str] = item

func put_off_reward_item(character: int, type_item: int) -> void :
	var char_str : String = str(character)
	var type_item_str : String = str(type_item)
	if characters_custom.has(char_str):
		characters_custom[char_str][type_item_str] = ""

func get_reward_item(character: int, type_item: int) -> String :
	var char_str : String = str(character)
	var type_item_str : String = str(type_item)
	if characters_custom.has(char_str):
		if characters_custom[char_str].has(type_item_str):
			return characters_custom[char_str][type_item_str]
		else:
			return ""
	else:
		return ""

func get_list_reward_items(character: int) -> Array :
	var char_str : String = str(character)
	if characters_custom.has(char_str):
		var list_items := []
		for type_item in RewardItemsConst.TYPE_ITEM.size():
			var type_item_str := str(type_item)
			if characters_custom[char_str].has(type_item_str):
				list_items.append(characters_custom[char_str][type_item_str])
		return list_items
	else:
		return ["", "", "", "", "", "", ""]
	
	

func to_dictionary() -> Dictionary :
	return characters_custom

func from_dictionary(dict: Dictionary) -> void :
	characters_custom.merge(dict, true)
