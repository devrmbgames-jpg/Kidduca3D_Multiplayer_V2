extends "res://content/game_save_cloud/game_cloud_base.gd"

var _game_kit = null
var SINGLETONE_NAME := "GameCenter"
var _token := ""
var _disabled := false
const RECONNECTION_TIME := 3.0


const PATH_CONFIG := "gs://rmb-knowledge-park-3d.appspot.com/users/%s/save.txt"
const PATH_LOCAL_CONFIG := "user://game_save_local.cfg"

var _save_name := ""

var firebase_uuid := ""
var is_auth := false

var is_loaded_game_center := false
var is_loaded_local_data := false
var is_resolved_data := false

var _save_data_local := {}
var _save_game_center := {}
var _save_firebase := {}


func _to_string() -> String:
	return "[GameCloudIOS]"

func _log(text: String) -> void :
	Logger.log_i(self, text)

func _ready() -> void:
	get_parent().id = "MACOS"
	_log("ready")
	_game_kit = GamePlugin.get_plugin(SINGLETONE_NAME)
	if _game_kit :
		_log("found %s" % SINGLETONE_NAME)
		_game_kit.call_deferred("authenticate")
		
		var timer := Timer.new()
		timer.wait_time = 0.1
		timer.autostart = true
		timer.connect("timeout", self, "_check_queue_events")
		add_child(timer)
		
	else :
		_log("not found %s" % SINGLETONE_NAME)

func _on_authenticate_handle(err_code: int, error: String) -> void :
	
	match err_code :
		OK :
			_game_kit.call_deferred("request_achievement_descriptions")
			is_auth = true
			emit_signal("connection_success")
		GKLocalPlayer.CODE_ERROR_CANCELED :
			_log("auth game center - canceled")
			emit_signal("connection_failed")
		_ :
			Logger.log_e(self, "auth game center - error. CODE:%d MSG:%s" % [err_code, error])
			emit_signal("connection_failed")
			
	pass

func connect_to_game_center() -> void :
	if _game_kit :
		emit_signal("start_connection")
		_log("authenticate game center")
		if _game_kit.is_authenticated():
			emit_signal("connection_success")
		else :
			_game_kit.authenticate()
	else :
		_log("game kit is is null")


func _on_auth_from_game_center_completed(uuid: String, err_code: int, error: String) -> void :
	_log("auth firebase from game center result- uuid:%s err_code:%d error:%s" % [uuid, err_code, error])
	if err_code == OK :
		firebase_uuid = uuid
		_update_auth()
	else :
		emit_signal("connection_failed")


func _resolve_save_data() -> Dictionary :
	_log("STEP 7 - resolve save data")
	_log("Resolve data")
	is_resolved_data = true
	
	var temp := GAME_STATE.new()
	temp.from_dictionary(_save_data_local)
	_log("resolve from local - %s" % str(temp.to_dictionary()))
	temp.from_dictionary(_save_game_center)
	_log("resolve from game center - %s" % str(temp.to_dictionary()))
	temp.from_dictionary(_save_firebase)
	var new_data := temp.to_dictionary()
	_log("resolve from firebase - %s" % str(new_data))
	_log("Resolve completed!")
	return new_data

func _check_queue_events() -> void :
	while _game_kit.get_pending_event_count() > 0 :
		if _disabled :
			return
		
		var event: Dictionary = _game_kit.pop_pending_event()
		_log(" QUEUE_EVENT: %s" % str(event))
		
		var type: String = event.get("type", "")
		if type == "achievement_descriptions" :
			var result: String = event.get("result", "")
			if result == "ok" :
				var names: PoolStringArray = event.get("names", [])
				var titles: PoolStringArray = event.get("titles", [])
				for i in names.size() :
					var key := names[i]
					var title := titles[i]
					Singletones.get_Achivment()._achivment_game_center_titles[key] = title
		
		
		match type :
			"load_game" :
				_parse_event_load_game(event)
			"authentication" :
				_parse_event_authentication(event)
			"award_achievement" :
				var result: String = event.get("ok", "error")
				if result == "ok" :
					pass
			_ :
				pass

func _json_to_dict(json: String) -> Dictionary :
	var result_json := JSON.parse(json)
	var dict: Dictionary = result_json.result
	var size := dict.get("size", -1) as int
	var bytes := var2bytes(dict.get("data", "")).decompress(size)
	var data: Dictionary = bytes2var(bytes)
	
	return data

func _dict_to_json(data: Dictionary) -> String :
	var bytes := var2bytes(data)
	var size := bytes.size()
	var _compress := bytes.compress()
	var dict := {
		"size" : size,
		"data" : data
	}
	
	return JSON.print(dict)

func _parse_event_load_game(event: Dictionary) -> void :
	
	var result: String = event.get("result", "")
	var json: String = event.get("save_data", "")
	_log("STEP 4 - parse game center")
	match result :
		"success" :
			var data := JSON.parse(json).result as Dictionary
			is_loaded_game_center = true
			_save_game_center = data if data else {}
		"empty" :
			is_loaded_game_center = true
		"error" : 
			Logger.log_i(self, " parse event error")
		_ :
			pass
	
	var res := _resolve_save_data()
	emit_signal("loaded_game_save", _save_name, OK, res, "")

func _parse_event_authentication(event: Dictionary) -> void :
	var result: String = event.get("result", "UNKNOW")
	var err_code: int = event.get("error_code", OK)
	var err_description: String = event.get("error_description", "")
	
	
	match result :
		"ok" :
			_game_kit.call_deferred("request_achievement_descriptions")
			connect_enable = true
			emit_signal("connection_success")
			
		"pending" :
			_log("connection pending...");
		"error" :
			emit_signal("connection_failed")
			_log("failed connection to game store, err_code: %s err_text: { %s }" % [err_code, err_description])
			if enable_recconection :
				_log("reconnection %s sec..." % str(RECONNECTION_TIME))
				get_tree().create_timer(RECONNECTION_TIME).connect("timeout", _game_kit, "authenticate")
		_ :
			Logger.log_e(self, " unknow result!")
	pass

func _update_auth() -> void :
	if _game_kit.is_authenticated() :
		connect_enable = true
		emit_signal("connection_success")

func connected_cloud() -> void :
	connect_to_game_center()

func disconnected_cloud() -> void :
	connect_enable = false

func is_connected_cloud() -> bool :
	return _game_kit.is_authenticated()

func request_save_game(save_name: String, data: Dictionary) -> void :
	if _disabled :
		return
	_save_name = save_name
	
	if not is_loaded_local_data :
		_load_local_file()
	_save_local_file(data)
	

func request_load_game(save_name: String) -> void :
	_save_name = save_name
	
	if _disabled :
		return
	
	_log("STEP 1 - request load game")
	
	
	_load_local_file()
	
	if not is_loaded_game_center :
		_load_game_center()
	

func request_load_game_force(save_name: String) -> void :
	_save_name = save_name
	_load_local_file()
	var res := _resolve_save_data()
	
	emit_signal("loaded_game_save", _save_name, OK, res, "")
	

func _load_local_file() -> void :
	_log("STEP 2 - load local file")
	_log("load save local file")
	var config := ConfigFile.new()
	config.load(PATH_LOCAL_CONFIG)
	_save_data_local = config.get_value("GENERAL", "save", {})
	is_loaded_local_data = true

func _save_local_file(data: Dictionary) -> void :
	var config := ConfigFile.new()
	config.load(PATH_LOCAL_CONFIG)
	config.set_value("GENERAL", "save", data)
	config.save(PATH_LOCAL_CONFIG)
	pass

func _load_game_center() -> void :
	_log("STEP 3 - load game center")
	_log("load save game center")
	if not _game_kit.is_authenticated() :
		_log("load game failed! is not authificated!!!")
		return
	var err_code = _game_kit.request_load_game()
	_log("request load games, err_code: %s" % str(err_code))


