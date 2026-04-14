tool
extends Reference

enum ItemComponent {
	BaseBox,
	BasePenta,
	BaseCilinder,
	
	RoofTringle,
	RoofPenta,
	RoofRect,
	
	WindowBox,
	WindowRound,
	WindowTringle,
	WindowCircle,
	
	DoorBox,
	DoorRound,
	DoorCircle,
	DoorTringle,
	
	StairSimple,
	StairSimpleV2,
	StairRamp,
	StairBook,
}

const DEFAULT_COMPONENT := {
	ItemComponent.BaseBox : true,
	ItemComponent.BasePenta : false,
	ItemComponent.BaseCilinder : false,
	
	ItemComponent.RoofTringle : true,
	ItemComponent.RoofPenta : false,
	ItemComponent.RoofRect : false,
	
	ItemComponent.WindowBox : true,
	ItemComponent.WindowRound : false,
	ItemComponent.WindowTringle : false,
	ItemComponent.WindowCircle : false,
	
	ItemComponent.DoorBox : true,
	ItemComponent.DoorRound : false,
	ItemComponent.DoorCircle : false,
	ItemComponent.DoorTringle : false,
	
	ItemComponent.StairSimple : true,
	ItemComponent.StairSimpleV2 : false,
	ItemComponent.StairRamp : false,
	ItemComponent.StairBook : false,
}



var components := DEFAULT_COMPONENT.duplicate()

var home := {
	
}
var data := {
	"components" : components,
	"home" : home
}


func reset() -> void :
	components = DEFAULT_COMPONENT.duplicate()
	home = {}
	
	data = {
		"components" : components,
		"home" : home
	}

func to_dict() -> Dictionary :
	return data

func from_dict(dict: Dictionary) -> void :
	
	var comp_list := dict.get("components") as Dictionary
	for key in comp_list :
		var val = comp_list[key]
		
		if val :
			data["components"][key] = val
	
	components = data["components"]
	
	var home_data := dict.get("home") as Dictionary
	data["home"] = home_data
	home = data["home"]
	
