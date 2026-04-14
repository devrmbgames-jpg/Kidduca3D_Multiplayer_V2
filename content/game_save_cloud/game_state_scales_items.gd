extends Reference
#class_name GameScalesItems

var scales_items_list := []

func push_scales_item(scales_item: String) -> void :
	if not scales_items_list.has(scales_item) :
		scales_items_list.append(scales_item)

func has_scales_item(scales_item: String) -> bool :
	return scales_items_list.has(scales_item)

func to_array() -> Array :
	return scales_items_list

func from_array(from: Array) -> void :
	for item in from :
		if not scales_items_list.has(item) :
			scales_items_list.append(item)
