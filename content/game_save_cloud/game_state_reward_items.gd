extends Reference
#class_name GameStateRewardItems

var reward_items := {
	"rmb_hat" : {"new" : true},
	"rmb_cape" : {"new" : true},
}

func push_reward_item(item) -> void :
	if not reward_items.has(item) :
		reward_items[item] = {
			"new" : true
		}

func set_not_new(item) -> void :
	if reward_items.has(item):
		reward_items[item]["new"] = false

func get_list_reward_items() -> Array :
	return reward_items.keys()

func has_reward_item(item) -> bool :
	return reward_items.has(item)

func get_new_item_count() -> int :
	var i := 0
	for key in reward_items :
		if reward_items[key].get("new", false) :
			i += 1
	
	return i

func is_new(item) -> bool :
	if reward_items.has(item):
		return reward_items[item]["new"]
	else:
		return false 

func to_dictionary() -> Dictionary :
	return reward_items

func from_dictionary(dict: Dictionary) -> void :
	reward_items.merge(dict, true)
	if not reward_items.has("rmb_hat") :
		reward_items["rmb_hat"] = {"new" : true}
	if not reward_items.has("rmb_cape") :
		reward_items["rmb_cape"] = {"new" : true}
		
