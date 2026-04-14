extends "res://content/game_save_cloud/game_cloud_base.gd"

const CFG_PATH := "user://save_data.cfg"
const GAME_STATE_GD := "res://content/game_save_cloud/game_state.gd"

const HASH_DATA := {
		"version" : GAME_STATE.VALIDATE_VERSION,
		"rmb_coin" : {
			"value_take" : 0,
			"value_buy" : 0,
			"value_cost" : 0
		},
		"rmb_pack" : {
			"value_take" : 0,
			"value_buy" : 0,
			"value_cost" : 0
		},
		"building" : {
		},
		"player_position" : Vector3.ZERO,
		"rmb_coins_objects" : {},
		"achivment" : [],
		"experience" : 0,
		"world_num" : 0,
		"character" : [0],
		"coloring" : [],
		"cloth_inventory" : [],
		"cloth_released" : [],
		"scales_items" : [],
		"build_notification_need_show" : {},
	}

func request_save_game(save_name: String, data: Dictionary) -> void :
	var cfg := ConfigFile.new()
	cfg.load(CFG_PATH)
	cfg.set_value("SAVES", save_name, data)
	cfg.save(CFG_PATH)
	
	emit_signal("saved", save_name, OK, data, "")
	

func request_load_game(save_name: String) -> void :
	var cfg := ConfigFile.new()
	cfg.load(CFG_PATH)
	
	
	
	var res: Dictionary = cfg.get_value("SAVES", save_name, {})
	if res.empty() :
		var game_state = load(GAME_STATE_GD).new()
		res = game_state.to_dictionary()
		cfg.set_value("SAVES", save_name, res)
		cfg.save(CFG_PATH)
	emit_signal("loaded_game_save", save_name, OK, res, "")
