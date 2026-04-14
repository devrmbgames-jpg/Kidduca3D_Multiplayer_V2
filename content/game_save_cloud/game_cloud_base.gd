extends Node
#class_name GameCloudBase

signal save_data_empty()
signal start_connection()
signal connection_failed()
signal connection_success()

signal loaded_game_save(save_name, error_code, data, error_description)
signal saved(save_name, error_code, data, error_description)

const GAME_STATE := preload("res://content/game_save_cloud/game_state.gd")

var enable_recconection := false
var connect_enable := false
var _connected := false
func connected_cloud() -> void :
	_connected = true
	emit_signal("connection_success")

func disconnected_cloud() -> void :
	_connected = false
	emit_signal("connection_failed")

func is_connected_cloud() -> bool :
	return _connected

func request_save_game(_save_name: String, _data: Dictionary) -> void :
	pass

func request_load_game(_save_name: String) -> void :
	
	pass

func request_load_game_force(_save_name: String) -> void :
	pass
