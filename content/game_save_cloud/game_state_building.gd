extends Reference
#class_name GameStateBuilding

class BuildingState :
	extends Reference
	var start_build_timestamp: int = INF
	var build_time: float = 4800000.0
	var time_left: float = 0.0
	var completed: = false
	
	func _init() -> void:
		start_build_timestamp = OS.get_unix_time()
	
	func to_dictionary() -> Dictionary :
		return {
			"start_build_timestamp": start_build_timestamp,
			"build_time" : build_time,
			"time_left" : time_left,
			"completed" : completed
		}
	
	func from_dictionary(dict: Dictionary) -> void :
		start_build_timestamp = min(dict.get("start_build_timestamp", INF) as int, start_build_timestamp) as int
		build_time = dict.get("build_time", 0.0) as float
		completed = dict.get("completed", false) as bool or completed
		time_left = max(dict.get("time_left", 0.0) as float, time_left)

var building_list := {}


func get_building_state(key: int) -> BuildingState :
	return building_list.get(key, null) as BuildingState

func write_time_left(key: int, time_left: float) -> void :
	var state := get_building_state(key)
	if state :
		state.time_left = time_left

func start_building(key: int, build_time: float) -> void :
	if not building_list.has(key):
		var state := BuildingState.new()
		state.build_time = build_time
		building_list[key] = state

func completed_building(key: int) -> void :
	var state := get_building_state(key)
	if not state :
		state = BuildingState.new()
		state.build_time = 0.0
		building_list[key] = state
	else :
		state.time_left = state.build_time
	state.completed = true

func from_dictionary(dict: Dictionary) -> void :
	for key in dict :
		var key_int := key as int
		var value: Dictionary = dict[key] as Dictionary
		if (value) :
			var current_state: BuildingState = building_list.get(key, null)
			if current_state :
				current_state.from_dictionary(value)
			else :
				var state := BuildingState.new()
				state.from_dictionary(value)
				building_list[key_int] = state

func to_dictionary() -> Dictionary :
	var ret := {}
	for key in building_list :
		var state: BuildingState = building_list[key]
		ret[key] = state.to_dictionary()
	
	return ret



