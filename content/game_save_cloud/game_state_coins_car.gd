extends Reference
#class_name GameStateCoinsCar

const GlobalSetups := preload("res://globals/global_setups.gd")

var value_take := 0 setget set_value_take
func set_value_take(val: int) -> void :
	if value_take != val :
		value_take = val

var value_cost := 0 setget set_value_cost
func set_value_cost(val: int) -> void :
	if value_cost != val :
		value_cost = val

var value_current := 0 setget ,get_value_current
func get_value_current() -> int :
	return value_take + GlobalSetups.START_COINS - value_cost

func cost(val: int) -> void :
	set_value_cost(value_cost + val)

func take(val: int) -> void :
	set_value_take(value_take + val)

func to_dictionary() -> Dictionary :
	return {
		"value_take" : value_take,
		"value_cost" : value_cost
	}

func from_dictionary(dict: Dictionary) -> void :
	value_take = max(dict.value_take as int, value_take) as int
	value_cost = max(dict.value_cost as int, value_cost) as int
