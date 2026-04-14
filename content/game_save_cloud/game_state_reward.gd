extends Reference
#class_name GameStateReward

var rewards := {}

func has_reward(key: String) -> bool :
	return rewards.get(key, false)

func push_reward(key: String) :
	rewards[key] = true

func to_dictionary() -> Dictionary :
	return rewards

func from_dictionary(dict: Dictionary) :
	for key in dict :
		rewards[key] = bool(rewards.get(key, false) | dict[key])
