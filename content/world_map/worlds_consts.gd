extends Reference
#class_name WorldsConsts

enum WORLDS {
	WORLD_FIRST,
	WORLD_SORTING,
	WORLD_HOME,
}

const WORLDS_LIST := {
	WORLDS.WORLD_FIRST : "res://content/world_map/world_first_placeholder.tscn",
	WORLDS.WORLD_SORTING : "res://content/world_map/world_sorting_placeholder.tscn",
	WORLDS.WORLD_HOME : "res://content/world_map/world_home.tscn"
}

static func get_world_path(world_num: int) -> String :
	return WORLDS_LIST[world_num]
