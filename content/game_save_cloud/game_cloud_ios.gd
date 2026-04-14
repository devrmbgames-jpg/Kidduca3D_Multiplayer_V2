extends "res://content/game_save_cloud/game_cloud_base.gd"

var _game_kit = null
var SINGLETONE_NAME := "GameCenter"
var _token := ""
var _disabled := false
const RECONNECTION_TIME := 3.0


const PATH_CONFIG := "gs://rmb-knowledge-park-3d.appspot.com/users/%s/save.txt"
const PATH_LOCAL_CONFIG := "user://game_save_local.cfg"
const SAVE_NAME_GAME_CENTER := "save_1"

var _save_name := ""

var is_auth_firebase := false
var firebase_uuid := ""
var is_auth := false

var is_loaded_firebase := false
var is_loaded_game_center := false
var is_loaded_local_data := false
var is_resolved_data := false

var _save_data_local := {}
var _save_game_center := {}
var _save_firebase := {}

var _local_player: Reference = null

func _to_string() -> String:
	return "[GameCloudIOS]"

func _log(text: String) -> void :
	Logger.log_i(self, text)

func _ready() -> void:
	_log("ready")
	_game_kit = GamePlugin.get_plugin(SINGLETONE_NAME)
	if _game_kit :
		_log("found %s" % SINGLETONE_NAME)
		
		
		FirebaseCore.connect("auth_from_game_center_completed", self, "_on_auth_from_game_center_completed")
		#FirebaseStore.set_root_path("gs://rmb-knowledge-park-3d.appspot.com")
		#FirebaseStore.connect("read_result", self, "_on_firebase_store_read_result")
		#FirebaseStore.connect("write_result", self, "_on_firebase_store_write_result")
		
		var timer := Timer.new()
		timer.wait_time = 0.5
		timer.autostart = true
		timer.connect("timeout", self, "_check_queue_events")
		add_child(timer)
		
		#_local_player = GameKitBuilder.create_local_player()
		if not _local_player :
			Logger.log_e(self, " local player from game kit builder is null!")
			return
		
		get_parent().id = _local_player.get_player_id()
		
		if not _local_player.has_signal("authenticate_handle") :
			Logger.log_e(_local_player, " not found signal ", "authenticate_handle")
			return
		
		_local_player.connect("authenticate_handle", self, "_on_authenticate_handle", [], CONNECT_DEFERRED)
	else :
		_log("not found %s" % SINGLETONE_NAME)

func _on_authenticate_handle(err_code: int, error: String) -> void :
	Logger.log_i(self, " auth handle err_code: %d error: %s" % [err_code, error])
	get_parent().id = _local_player.get_player_id()
	
	match err_code :
		OK :
			Logger.log_i(self, " auth handle success!")
			if _game_kit :
				_game_kit.call_deferred("request_achievement_descriptions")
			
			#is_loaded_game_center = true
			
			if is_auth_firebase :
				connect_enable = true
				emit_signal("connection_success")
			else :
				Logger.log_i(self, " firebase is not auth!")
				connect_to_firebase()
			
		GKLocalPlayer.CODE_ERROR_CANCELED :
			_log("auth game center - canceled")
			emit_signal("connection_failed")
		_ :
			Logger.log_e(self, "auth game center - error. CODE:%d MSG:%s" % [err_code, error])
			emit_signal("connection_failed")
			
	pass

func connect_to_game_center() -> void :
	if _local_player :
		emit_signal("start_connection")
		_log("authenticate game center")
		if _local_player.get_authenticated():
			_log(" gamecenter authenticated!")
			#is_loaded_game_center = true
			
			if is_auth_firebase :
				_log(" firebase authenticated!")
				connect_enable = true
				emit_signal("connection_success")
			else :
				connect_to_firebase()
			
		else :
			_log(" gamecenter authenticate...")
			_local_player.authenticate()
	else :
		Logger.log_e(self, "game kit is is null")


func connect_to_firebase() -> void :
	_log("authenticate firebase")
	FirebaseCore.auth_from_game_center()

func _on_auth_from_game_center_completed(uuid: String, err_code: int, error: String) -> void :
	_log("auth firebase from game center result- uuid:%s err_code:%d error:%s" % [uuid, err_code, error])
	if err_code == OK :
		firebase_uuid = uuid
		is_auth_firebase = true
		connect_enable = true
		emit_signal("connection_success")
	else :
		emit_signal("connection_failed")

func _on_firebase_store_read_result(err_code: int, data_save, error: String) -> void :
	_log("firebase read code:%d data:%s error:%s" % [err_code, String(data_save), error])
	_log("STEP 6 - parse firebase save")
	_log("firebase read result err_code:%d" % err_code )
	
	if err_code == OK :
		if data_save :
			if data_save is String :
				var data_str := data_save as String
				var parse := JSON.parse(data_str)
				if parse.error == OK :
					var result = parse.result as Dictionary
					if result :
						_save_firebase = result
	
	if err_code in [OK, FirebaseConsts.ERR_FIR_STORAGE_ERROR_CODE_OBJECT_NOT_FOUND] :
		var state := _resolve_save_data()
		emit_signal("loaded_game_save", _save_name, OK, state, error)
		is_loaded_firebase = true
	

func _on_firebase_store_write_result(err_code: int, url: String, error: String) :
	_log("firebase write code:%d URL:%s error:%s" % [err_code, url, error])
	emit_signal("saved", _save_name, err_code, {}, error)


func _resolve_save_data() -> Dictionary :
	_log("STEP 7 - resolve save data")
	_log("Resolve data")
	is_resolved_data = true
	
	
	var state := Singletones.get_GameSaveCloud().game_state
	if _save_data_local :
		state.from_dictionary(_save_data_local)
		_log("resolve from local - %s" % str(state.to_dictionary()))
	if _save_game_center :
		state.from_dictionary(_save_game_center)
		_log("resolve from game center - %s" % str(state.to_dictionary()))
	if _save_firebase :
		state.from_dictionary(_save_firebase)
		_log("resolve from firebase - %s" % str(state))
	_log("Resolve completed!")
	return state.to_dictionary()

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
		
		var token: String = event.get("player_id", "")
		if not token.empty() :
			_token = token
			get_parent().id = token
		
		
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
	var _save_name_GC: String = event.get("save_name", SAVE_NAME_GAME_CENTER)
	if _save_name_GC != SAVE_NAME_GAME_CENTER :
		return
	#var _error_text: String = event.get("error", "")
	#var _error_code: int = event.get("error_code", ERR_UNAVAILABLE) as int 
	var result: String = event.get("result", "")
	var json: String = event.get("save_data", "")
	_log("STEP 4 - parse game center")
	match result :
		"success" :
			var parse: JSONParseResult = JSON.parse(json) as JSONParseResult
			if parse.error == OK :
				var data := parse.result as Dictionary
				is_loaded_game_center = true
				
				_save_game_center = data if data else {}
				
				var state := _resolve_save_data()
				emit_signal("loaded_game_save", _save_name, OK, state, "")
			
			_load_firebase()
		"empty" :
			is_loaded_game_center = true
			_load_firebase()
		"error" :
			_load_firebase()
		_ :
			pass
	pass

func _parse_event_authentication(event: Dictionary) -> void :
	var result: String = event.get("result", "UNKNOW")
	var err_code: int = event.get("error_code", OK)
	var err_description: String = event.get("error_description", "")
	
	Logger.log_i(self, "parse event")
	match result :
		"ok" :
			Logger.log_i(self, " auth gamecenter success!")
			_game_kit.call_deferred("request_achievement_descriptions")
			if not is_auth_firebase :
				connect_to_firebase()
		"pending" :
			_log("connection pending...");
		"error" :
			emit_signal("connection_failed")
			_log("failed connection to game store, err_code: %s err_text: { %s }" % [err_code, err_description])
			if enable_recconection :
				_log("reconnection %s sec..." % str(RECONNECTION_TIME))
				get_tree().create_timer(RECONNECTION_TIME).connect("timeout", _game_kit, "authenticate")
		_ :
			Logger.log_e(self, " unknow result")
	pass

func _update_auth() -> void :
	if is_auth_firebase and _local_player.get_authenticated() :
		connect_enable = true
		emit_signal("connection_success")

func connected_cloud() -> void :
	connect_to_game_center()

func disconnected_cloud() -> void :
	connect_enable = false

func is_connected_cloud() -> bool :
	return is_auth_firebase and _local_player.get_authenticated()

func request_save_game(save_name: String, data: Dictionary) -> void :
	if _disabled :
		return
	_save_name = save_name
	
	if not is_loaded_local_data :
		_load_local_file()
	_save_local_file(data)
	
	if is_loaded_firebase :
		_save_firebase_data(data)
	
	if is_loaded_game_center :
		_save_game_center(data)

func request_load_game(save_name: String) -> void :
	_save_name = save_name
	
	if _disabled :
		return
	
	_log("STEP 1 - request load game")
	
	
	_load_local_file()
	var state := _resolve_save_data()
	emit_signal("loaded_game_save", _save_name, OK, state, "")
	
	if not is_loaded_game_center :
		_load_game_center()
	if is_auth_firebase and not is_loaded_firebase :
		_load_firebase()

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
	if not _local_player.get_authenticated() :
		_log("load game failed! is not authificated!!!")
		return
	var err_code = _game_kit.request_load_game()
	_log("request load games, err_code: %s" % str(err_code))

func _load_firebase() -> void :
	_log("STEP 5 - load firebase")
	_log("load save firebase")
	_log("request load firebase save " + (PATH_CONFIG % firebase_uuid))
	#FirebaseStore.read_string_from_file(PATH_CONFIG % firebase_uuid)


func _save_firebase_data(data: Dictionary) -> void :
	_log("save firebase")
	var parse := JSON.print(data)
	#FirebaseStore.write_string_to_file(PATH_CONFIG % firebase_uuid, parse)

func _save_game_center(data: Dictionary) -> void :
	_log("save game center")
	var parse := JSON.print(data)
	if _game_kit and parse :
		_game_kit.request_save_game(SAVE_NAME_GAME_CENTER, parse)
