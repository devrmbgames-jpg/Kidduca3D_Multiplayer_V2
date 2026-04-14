extends Reference
#class_name GameStateCoins

var coins := {}

func _to_string() -> String:
	return "[GameStateCoins: %d]" % get_instance_id()

func take_coin(node: Spatial) -> void :
	take_coin_path(node.get_path())

func take_coin_path(path: NodePath) -> void :
	var hs := hash(path)
	var hs_str := str(hs)
	
	coins[hs_str] = true

func take_coin_id(id: int) -> void :
	coins[str(id)] = true

func has_coin_taked(node: Spatial) -> bool :
	return has_coin_taked_path(node.get_path())

func has_coin_taked_path(path: NodePath) -> bool :
	var hs := hash(path)
	var hs_str := str(hs)
	return coins.get(hs_str, false)

func has_coin_taked_from_id(id: int) -> bool :
	return coins.get(str(id), false)

func to_dictionary() -> Dictionary :
	return coins

func from_dictionary(dict: Dictionary) -> void :
	coins.merge(dict, true)
