extends Reference
#class_name GameStateAchivment

var achivment_list := []

func push_achivment(achivment: String) -> void :
	if not achivment_list.has(achivment) :
		achivment_list.append(achivment)

func has_achivment(achivment: String) -> bool :
	return achivment_list.has(achivment)


func to_array() -> Array :
	return achivment_list

func from_array(from_list: Array) -> void :
	for achivment in from_list :
		if not achivment_list.has(achivment) :
			achivment_list.append(achivment)
