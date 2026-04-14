extends Reference
#class_name GameStateCars

const CarConst := preload("res://content/vehicle/car_const.gd")

var car_open := {
	CarConst.TYPE_CAR.OLD : {
		"drive_level" : 0,
		"wheels_level" : 0,
		"skins" : [0],
		"current_skin" : 0,
	}
}
var car_current := 0

func push_car(type_car: int) -> void :
	if not car_open.has(type_car):
		car_open[type_car] = {
			"drive_level" : 0,
			"wheels_level" : 0,
			"skins" : [0],
			"current_skin" : 0,
		}
		car_current = type_car

func push_car_current(type_car: int) -> void :
	if car_open.has(type_car):
		car_current = type_car

func push_level_drive(type_car: int, level: int) -> void :
	if car_open.has(type_car):
		car_open[type_car].drive_level = level

func push_level_wheels(type_car: int, level: int) -> void :
	if car_open.has(type_car):
		car_open[type_car].wheels_level = level

func push_skin(type_car: int, skin: int) -> void :
	if car_open.has(type_car):
		if not car_open[type_car].skins.has(skin):
			car_open[type_car].skins.append(skin)
			car_open[type_car].current_skin = skin

func push_skin_current(type_car: int, skin: int) -> void :
	if car_open.has(type_car):
		if car_open[type_car].skins.has(skin):
			car_open[type_car].current_skin = skin

func has_car(type_car: int) -> bool :
	return car_open.has(type_car)

func has_skin(type_car: int, skin: int) -> bool :
	if car_open.has(type_car):
		return car_open[type_car].skins.has(skin)
	else:
		return false

func get_level_drive(type_car: int) -> int :
	if car_open.has(type_car):
		return car_open[type_car].drive_level
	else:
		return -1

func get_level_wheels(type_car: int) -> int :
	if car_open.has(type_car):
		return car_open[type_car].wheels_level
	else:
		return -1

func get_skin_current(type_car: int) -> int :
	if car_open.has(type_car):
		return car_open[type_car].current_skin
	else:
		return -1

func get_car_current() -> int :
	return car_current

func get_open_cars_list() -> Array :
	return car_open.keys()

func get_skins_lits(type_car: int) -> Array :
	if car_open.has(type_car):
		return car_open[type_car].skins
	else:
		return []

func to_dictionary() -> Dictionary :
	return {
		"car_open" : car_open,
		"car_current" : car_current
	}

func from_dictionary(dict: Dictionary) -> void :
	car_current = dict.get("car_current", 0) as int
	
	for key in dict.car_open :
		var car_type = key as int
		
		if not car_open.has(car_type):
			var data: Dictionary = dict.car_open[key]
			var drive_level := data.drive_level as int
			var wheels_level := data.wheels_level as int
			var skins := []
			for id in data.skins :
				skins.append(id as int)
			
			var current_skin := data.current_skin as int
			
			car_open[car_type] = {
				"drive_level" : drive_level,
				"wheels_level" : wheels_level,
				"skins" : skins,
				"current_skin" : current_skin,
			}
		else:
			var car: Dictionary = car_open[car_type]
			var car_drive_level := car.drive_level as int
			var car_wheels_level := car.wheels_level as int
			
			var data: Dictionary = dict.car_open[key]
			var drive_level := data.drive_level as int
			var wheels_level := data.wheels_level as int
			var current_skin := data.current_skin as int
			
			car.drive_level = max(car_drive_level, drive_level)
			car.wheels_level = max(car_wheels_level, wheels_level)
			car.current_skin = current_skin
			
			for id in data.skins :
				var skin = id as int
				if not car.skins.has(skin):
					car.skins.append(skin)
			
			



