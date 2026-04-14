extends "res://content/game_save_cloud/game_cloud_base.gd"

const GameState := preload("res://content/game_save_cloud/game_state.gd")

var _accessable_server := false
var _started_equest_server_side := false
var _token := ""

var _is_auth_gpgs := false
var _is_auth_firebase := false

var _is_save_loaded_gpgs := false
var _is_save_loaded_firebase := false

var _save_data_local := {}
var _save_data_gpgs := {}
var _save_data_firebase := {}

var _save_name_temp := ""
var _uuid := ""

const OAUTH2_CLIENT := "950177203640-g6pa67483msu663qftsij9e7egh442nr.apps.googleusercontent.com"
#const OAUTH2_CLIENT := "950177203640-kofn9kq54ebdn44vospc55567chrsb52.apps.googleusercontent.com"
#const OAUTH2_CLIENT := "950177203640-2t0dbf6h884oo7d9nf52b5mguibgiil9.apps.googleusercontent.com"
const PATH_CONFIG := "gs://rmb-knowledge-park-3d.appspot.com/users/%s/save.txt"
const PATH_LOCAL_CONFIG := "user://game_save_local.cfg"



func _to_string() -> String:
	return "[GameCloudGoogle]"

func _ready() -> void:
	GamesSignInClient.connect("sign_in_success", self, "_on_connected")
	GamesSignInClient.connect("sign_in_failure", self, "_on_connected_failed")
	GamesSignInClient.connect("request_server_side_access_success", self, "_on_request_server_side_access_success")
	GamesSignInClient.connect("request_server_side_access_failure", self, "_on_request_server_side_access_failure")
	GamesSignInClient.connect("is_user_authenticated_success", self, "_on_connected")
	GamesSignInClient.connect("is_user_authenticated_failure", self, "_on_connected_failed")
	SaveLoadGameClient.connect("saved", self, "_on_saved")
	SaveLoadGameClient.connect("loaded", self, "_on_loaded")
	
	FirebaseCore.connect("auth_from_game_center_completed", self, "_on_firebase_auth_from_game_center_completed")
	FirebaseStore.set_root_path("gs://rmb-knowledge-park-3d.appspot.com")
	FirebaseStore.connect("read_result", self, "_on_firebase_read_result")
	FirebaseStore.connect("write_result", self, "_on_firebase_write_result")
	pass

func _on_firebase_read_result(err_code: int, data_raw, error: String) -> void :
	Logger.log_i(self, " firebase read result CODE:%d , error:%s" % [err_code, error])
	if err_code == OK :
		if data_raw :
			if data_raw is String :
				var data_str := data_raw as String
				var result = JSON.parse(data_str).result
				if result :
					var data := result as Dictionary
					if data :
						_save_data_firebase = data
	
	if err_code in [OK, FirebaseConsts.ERR_FIR_STORAGE_ERROR_CODE_OBJECT_NOT_FOUND] :
		var state := _resolve_save_data()
		var data := state.to_dictionary()
		emit_signal("loaded_game_save", _save_name_temp, OK, data, error)
		_is_save_loaded_firebase = true

func _on_firebase_write_result(err_code: int, url: String, error: String) -> void :
	Logger.log_i(self, " firebase write result code:%d, url:%s, error:%s" % [err_code, url, error])
	emit_signal("saved", _save_name_temp, err_code, {}, error)


func _on_firebase_auth_from_game_center_completed(uuid: String, err_code: int, error: String) -> void :
	Logger.log_i(self, " firebase auth completed CODE:%s , UUID:%s, ERROR:%s" % [err_code, uuid, error])
	if err_code == OK :
		_is_auth_firebase = true
		_uuid = uuid
		emit_signal("connection_success")

func _on_request_server_side_access_success(token) -> void :
	Logger.log_i(self, " request server side access success token")
	_accessable_server = true
	_token = token
	#FirebaseCore.auth_from_gpgs_from_auth_code(OAUTH2_CLIENT)

func _on_request_server_side_access_failure() -> void :
	Logger.log_i(self, " request server side access failed token")
	_accessable_server = false
	get_tree().create_timer(5.0).connect("timeout", self, "_request_server_side")

func _request_server_side() -> void :
	Logger.log_i(self, " request server side from OAUTH2")
	if _accessable_server :
		return
	
	GamesSignInClient.request_server_side_access(OAUTH2_CLIENT, false)

func _on_loaded(save_name: String, json: String, err_code: int, err_text: String) -> void :
	Logger.log_i(self, " on loaded save_name: %s err_code: %d  err_text: %s" % [save_name, err_code, err_text])
	
	if json and json is String and not json.empty() :
		var result = JSON.parse(json).result
		if result :
			var data := result as Dictionary
			if data :
				_save_data_gpgs = data
	
	if err_code == OK:
		var state := _resolve_save_data()
		var save_data := state.to_dictionary()
		_is_save_loaded_gpgs = true
		emit_signal("loaded_game_save", save_name, err_code, save_data, err_text)


func _on_saved(save_name: String, err_code: int, err_text: String) -> void :
	Logger.log_i(self, " on saved save_name: %s err_code: %d err_text: %s" % [save_name, err_code, err_text])
	emit_signal("saved", save_name, err_code, {}, err_text)

func _on_connected(connected) -> void :
	Logger.log_i(self, " on connected - %s" % connected)
	if connected :
		_is_auth_gpgs = true
		FirebaseCore.auth_from_gpgs_from_auth_code(OAUTH2_CLIENT)
	else :
		_is_auth_gpgs = false
		emit_signal("connection_failed")
	

func _check_connected() -> void :
	if _is_auth_gpgs and _is_auth_firebase :
		emit_signal("connection_success")

func _on_connected_failed() -> void :
	Logger.log_i(self, " on connected failed")
	_is_auth_gpgs = false
	emit_signal("connection_failed")

func _on_disconnected() -> void :
	pass

func connected_cloud() -> void :
	Logger.log_i(self, " connecting...")
	if GamesSignInClient.is_silent_signed :
		_on_connected(true)


func disconnected_cloud() -> void :
	pass

func is_connected_cloud() -> bool :
	return _is_auth_gpgs or _is_auth_firebase

func _save_in_local(data: Dictionary) -> void :
	var cfg := ConfigFile.new()
	
	cfg.load(PATH_LOCAL_CONFIG)
	cfg.set_value("GENERAL", "SAVE", data)
	cfg.save(PATH_LOCAL_CONFIG)

func _load_from_local() -> Dictionary :
	var cfg := ConfigFile.new()
	cfg.load(PATH_LOCAL_CONFIG)
	var data: Dictionary = cfg.get_value("GENERAL", "SAVE", {})
	return data

func request_save_game(save_name: String, data: Dictionary) -> void :
	Logger.log_i(self, " request save game - save_name: %s" % save_name)
	
	_save_name_temp = save_name
	
	_save_in_local(data)
	
	var parse := JSON.print(data)
	
	if _is_save_loaded_gpgs :
		SaveLoadGameClient.save_game(_save_name_temp, parse, "")
	
	if _is_save_loaded_firebase :
		FirebaseStore.write_string_to_file(PATH_CONFIG % _uuid, parse)

func request_load_game(save_name: String) -> void :
	Logger.log_i(self, " request load game - save_name: %s" % save_name)
	
	_save_name_temp = save_name
	
	_save_data_local = _load_from_local()
	var state := _resolve_save_data()
	var save_data := state.to_dictionary()
	emit_signal("loaded_game_save", save_name, OK, save_data, "")
	
	
	SaveLoadGameClient.load_game(save_name)
	if _uuid :
		FirebaseStore.read_string_from_file(PATH_CONFIG % _uuid)

func _resolve_save_data() -> GameState :
	var state := GAME_STATE.new()
	state = Singletones.get_GameSaveCloud().game_state
	
	if _save_data_local :
		state.from_dictionary(_save_data_local)
	if _save_data_gpgs :
		state.from_dictionary(_save_data_gpgs)
	if _save_data_firebase :
		state.from_dictionary(_save_data_firebase)
	
	return state
