extends Reference
#class_name GameStateDress

var cloth_inventory_list := []
var cloth_released_list := []

func push_cloth_to_inventory(cloth: String) -> void :
	if not cloth_inventory_list.has(cloth) :
		cloth_inventory_list.append(cloth)

func push_cloth_released(cloth: String) -> void :
	if not cloth_released_list.has(cloth) :
		cloth_released_list.append(cloth)

func has_cloth_in_inventory(cloth: String) -> bool :
	return cloth_inventory_list.has(cloth)

func has_cloth_released(cloth: String) -> bool :
	return cloth_released_list.has(cloth)

func to_array_cloth_inventory() -> Array :
	return cloth_inventory_list

func to_array_cloth_released() -> Array :
	return cloth_released_list

func from_array_cloth_inventory(from: Array) -> void :
	for item in from :
		if not cloth_inventory_list.has(item) :
			cloth_inventory_list.append(item)

func from_array_cloth_released(from: Array) -> void :
	for item in from :
		if not cloth_released_list.has(item) :
			cloth_released_list.append(item)
