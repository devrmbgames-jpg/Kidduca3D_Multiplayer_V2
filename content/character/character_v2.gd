extends KinematicBody

const NetworkConst := preload("res://content/network/network_const.gd")
const LevelColorConst := preload("res://content/character/name_player/level_color_const.gd")
const CharacterAnimations := preload("res://resources/models/character_v2/character_animation_v3.gd")
const FCM := preload("res://content/fcm/fcm.gd")
const GlobalSetups := preload("res://globals/global_setups.gd")
const SMOOTH_ROT := 0.1

const DANCE_1 := 0
const DANCE_2 := 1
const VICTORY := 2
const WAIVING := 3

export(bool) var enabled := false setget set_enabled
func set_enabled(val: bool) -> void :
	enabled = val
export(bool) var freez := false
export(bool) var move_force := false
export(bool) var run_force := false
export(float) var target_min_distance := 0.5
export(float) var jump := 5.0
export(Vector3) var snap := Vector3.DOWN * 1
export(Vector3) var direction := Vector3()
export(Vector3) var linear_velocity := Vector3()
export(bool) var stop_on_slope := false
export(int) var max_slides := 4
export(float) var floor_max_angle :=  0.785398 * 1.5
export(bool) var infinite_inertia := true

var in_game := false
var in_lobby := false
var is_host := false

export(PackedScene) var pkg: PackedScene = null

export(Curve) var curve_smooth_rot

var deth_zone_z := 300

onready var _instance_placeholder := $Core/Character
onready var _down_cast := $RayCastDown
onready var _forward_cast := $RayCastForwad
onready var _smiles := $Core/Smiles
onready var _name_player := $Core/NamePlayer
onready var _core := $Core
var _character: CharacterAnimations = null

var _look_at_model := transform.origin
var _look_at_model_last := transform.origin
var _gravity := Vector3.ZERO
var _total_gravity := Vector3.ZERO

var _fcm: FCM = null

var target_move := Vector3.ZERO
var _prev_poses := [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
var _tick_prev_pos := 0
var start_game_position := Transform.IDENTITY


# network
enum TYPE_DATA {
	MOVE_PLAYER,
	ALL_DATA,
	GIVE_ME_ALL_DATA,
	NAME_PLAYER,
	CLOTHES,
	IDX_CHARACTER,
	NUM_WORLD,
	SMILE,
	IN_GAME,
	ANIMATION,
	IN_LOBBY,
	IS_HOST
}

enum NAME_DATA {
	TYPE_UPDATE,
	TYPE,
	IDX_OBJ,
	
	MOVE_PLAYER,
	NAME_PLAYER,
	CLOTHES,
	IDX_CHARACTER,
	NUM_WORLD,
	SMILE,
	IN_GAME,
	ANIMATION,
	LEVEL_ACHIV,
	IS_ACTIVE_SUB,
	IN_LOBBY,
	IS_HOST
}

var _data_network_move_player := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.MOVE_PLAYER,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.MOVE_PLAYER : null
}

var _data_network_all_data := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.ALL_DATA,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.NAME_PLAYER : "",
	NAME_DATA.CLOTHES : [],
	NAME_DATA.IDX_CHARACTER : 0,
	NAME_DATA.NUM_WORLD : 0,
	NAME_DATA.IN_GAME : false,
	NAME_DATA.LEVEL_ACHIV : 0.0,
	NAME_DATA.IS_ACTIVE_SUB : false,
	NAME_DATA.IN_LOBBY : false,
	NAME_DATA.IS_HOST : false,
}

var _data_network_name_player := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.NAME_PLAYER,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.NAME_PLAYER : ""
}

var _data_network_clothes := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.CLOTHES,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.CLOTHES : []
}

var _data_network_idx_character := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.IDX_CHARACTER,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.CLOTHES : [],
	NAME_DATA.IDX_CHARACTER : 0
}

var _data_network_num_world := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.NUM_WORLD,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.NUM_WORLD : 0
}

var _data_network_smile := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.SMILE,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.SMILE : 0
}

var _data_network_in_game := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.IN_GAME,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.IN_GAME : false
}

var _data_network_animation := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.ANIMATION,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.ANIMATION : ""
}

var _data_network_in_lobby := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.IN_LOBBY,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.IN_LOBBY : false
}

var _data_network_is_host := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK,
	NAME_DATA.TYPE : TYPE_DATA.IS_HOST,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.IS_HOST : false
}

var _data_network_give_me_all_data := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER,
	NAME_DATA.TYPE : TYPE_DATA.GIVE_ME_ALL_DATA,
}


var _current_clothe := []

func _ready() -> void: 
	name = str(randi())
	if _instance_placeholder :
		if not Singletones.get_Global().character_paked_path.empty() :
			var character_pkg: PackedScene = ResourceLoader.load(Singletones.get_Global().character_paked_path, "", GlobalSetups.NO_CACHED) as PackedScene
			_character = _instance_placeholder.create_instance(false, character_pkg)
		elif pkg :
			_character = _instance_placeholder.create_instance(false, pkg)
		else :
			_character = _instance_placeholder
	
	if not _character :
		return
	
	_fcm = _character.fcm
	Singletones.get_Global().player_character = self
	
	var name_pl : String = Singletones.get_GameSaveCloud().game_state.profile.get_name()
	_name_player.set_name(name_pl)
	
	var is_active_sub := false
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree:
		if OS.get_name() == "Windows" and scene_tree.root.get_node_or_null("SteamManager") :
			is_active_sub = true
		else:
			var subs_checker :=  Singletones.get_SubsChecker()
			if subs_checker :
				is_active_sub = subs_checker.is_subs_active()
	_name_player.set_premium(is_active_sub)
	
	_core.translation.y = _character.y_offset
	
	get_tree().create_timer(1.5).connect("timeout", self, "_send_give_me_all_data")
	get_tree().create_timer(1.8).connect("timeout", self, "_send_all_data")

func change_pkg() -> void:
	if not _instance_placeholder :
		return
	
	var trans_player = _character.global_transform
	_character.queue_free()
	_character = null
	
	if not Singletones.get_Global().character_paked_path.empty() :
		var character_pkg: PackedScene = ResourceLoader.load(Singletones.get_Global().character_paked_path, "", GlobalSetups.NO_CACHED) as PackedScene
		_character = _instance_placeholder.create_instance(false, character_pkg)
	elif pkg :
		_character = _instance_placeholder.create_instance(false, pkg)
	else :
		_character = _instance_placeholder
		
	_character.global_transform = trans_player
	_core.translation.y = _character.y_offset
	_fcm = _character.fcm

func _exit_tree() -> void:
	Singletones.get_Global().player_character = null

func force_push(vec: Vector3, offset: Vector3) -> void :
	transform.origin += offset
	_fcm.push_state(FCM.FALL)
	linear_velocity += vec

func get_character() -> Spatial :
	return _character as Spatial

func get_character_pkg_path() -> String :
	if not Singletones.get_Global().character_paked_path.empty():
		return Singletones.get_Global().character_paked_path
	else:
		if pkg :
			return pkg.resource_path 
	return "res://resources/models/character_v2/full/dog/dog_player.tscn"

func update_reward_items(new_clother := []) -> void :
	Logger.log_i(self, " update rewardes ", new_clother)
	
	_current_clothe = new_clother
	if new_clother.empty() :
		_character.update_reward_items()
	else :
		_character.update_reward_items(new_clother)

func get_reward_items() -> Array :
	if _character:
		_character.get_reward_items()
	return _current_clothe

func show_smile(smile: int) -> void :
	var idx_char : int = Singletones.get_GameSaveCloud().game_state.current_charscter_idx
	_smiles.show_smile_character(smile, idx_char)
	send_smile(smile)


func show_star_to_new_level(level: float) -> void :
	_name_player.show_star_to_new_level(level)


func update_network_data(data: Dictionary) -> void :
	match data[NAME_DATA.TYPE] as int:
		TYPE_DATA.GIVE_ME_ALL_DATA:
			_send_all_data()

func update_fcm_force() -> void :
	if _fcm :
		_fcm.emit_signal("change_state") 
		

###############################################################################
########### PHYSICS ###########################################################
###############################################################################

func _physics_process_setup_prev_poses() -> void :
	_tick_prev_pos += 1
	if _tick_prev_pos > 5:
		_tick_prev_pos = 0
		if not _character or not is_instance_valid(_character):
			return
		if not in_game and not in_lobby:
			for i in range(0, _prev_poses.size() - 1):
				_prev_poses[i] = _prev_poses[i + 1]
			_prev_poses[_prev_poses.size() - 1] = _character.global_position
		else:
			for i in range(0, _prev_poses.size()):
				_prev_poses[i] = start_game_position.origin

func _physics_process_gravity(delta: float) -> void :
	var state := PhysicsServer.body_get_direct_state(get_rid())
	_total_gravity = state.get_total_gravity()
	if is_on_floor() :
		_gravity = Vector3.ZERO
	else :
		_gravity += _total_gravity * delta

func _physics_process_apply_velocity(_delta: float) -> void :
	var v := Vector3.ZERO
	if _fcm:
		var state : int = _fcm.get_current_state()
		match state:
			FCM.WALK:
				v = Vector3.BACK * 0.455
			FCM.RUN:
				v = Vector3.BACK * 1.883 * 1.5
			FCM.JUMP_FORWARD:
				v = Vector3(0.0, 1.883, 1.883)
#			FCM.JUMP:
#				v = Vector3(0.0, 1.883, 0.0)
	
	#var v: Vector3 = _character.get_root_motion_transform().origin / delta
	v = v.rotated(Vector3.UP, _character.rotation.y)
	v.x *= 2.5
	v.z *= 2.5
	if v.y > 0 :
		#v.y *= 8
		v.y *= 3.5
	
	linear_velocity = v
	
	if is_on_floor() :
		pass
	else :
		linear_velocity += _gravity
	

func _physics_process_character(delta: float, with_snap := true) -> void :
	_physics_process_gravity(delta)
	_physics_process_apply_velocity(delta)
	
	if _down_cast.is_colliding() and _forward_cast.is_colliding() :
		on_jump_forward()
	
	var up := _total_gravity.normalized() * -1
	
	if with_snap :
		linear_velocity = move_and_slide_with_snap(
			linear_velocity,
			snap,
			up,
			stop_on_slope,
			max_slides,
			floor_max_angle,
			infinite_inertia
		)
	else :
		linear_velocity = move_and_slide(
			linear_velocity,
			up,
			stop_on_slope,
			max_slides,
			floor_max_angle,
			infinite_inertia
		)
	
	if _character and is_instance_valid(_character):
		_smiles.rotation.y = _character.rotation.y


### MATCHING STATE

func _state_process(delta: float) -> void :
	
	var with_snap := true
	var enable_physics := true
	match _fcm.get_current_state() :
		FCM.IDLE :
			if is_on_floor() :
				if direction.length() > 0.1 :
					_fcm.push_state(FCM.WALK)
			else :
				_fcm.push_state(FCM.FALL)
		FCM.WALK :
			if is_on_floor() :
				
				if direction.length() > 0.55 :
					_fcm.push_state(FCM.RUN)
				elif direction.length() <= 0.1 :
					_fcm.pop_state()
			else :
				_fcm.push_state(FCM.FALL)
				
		FCM.RUN :
			if is_on_floor() :
				if direction.length() <= 0.55 :
					_fcm.pop_state()
			else :
				_fcm.push_state(FCM.FALL)
		FCM.JUMP :
			with_snap = false
		FCM.JUMP_FORWARD :
			with_snap = false
		FCM.FALL :
			if is_on_floor() :
				_fcm.pop_state()
		FCM.SIT :
			enable_physics = false
		FCM.ACTION :
#			var rotation_char: Transform = _character.get_root_motion_transform()
#			rotation_char.origin = Vector3.ZERO
#			$Core.transform *= rotation_char
			enable_physics = false
	
	
	
	if enable_physics :
		_physics_process_character(delta, with_snap)


func _physics_process(delta: float) -> void :
	_physics_process_setup_prev_poses()
	
	if freez :
		return
	
	if _character :
		if move_force :
			_ai_move()
		elif run_force :
			_ai_run()
		_state_process(delta)


func on_jump() -> void:
	_character.jump()

func on_jump_forward() -> void :
	_character.jump_forward()

func _ai_move() -> void :
	var global_pos := global_transform.origin
	var distance := global_pos.distance_to(target_move)
	if distance > target_min_distance :
		direction = global_pos.direction_to(target_move).normalized() * 0.5
	else :
		direction = Vector3.ZERO

func _ai_run() -> void :
	var global_pos := global_transform.origin
	var distance := global_pos.distance_to(target_move)
	if distance > target_min_distance :
		direction = global_pos.direction_to(target_move).normalized()
	else :
		direction = Vector3.ZERO

func on_changed_direction(new_direction: Vector3) -> void:
	if enabled :
		new_direction.y = 0.0
		
		direction = new_direction
		if direction.length() > 0.1 :
			if _fcm.get_current_state() in [FCM.ACTION, FCM.SIT] :
				_fcm.pop_state() 


func _process(delta: float) -> void:
	direction.y = 0.0
	if _character and direction.length() > 0.1 :
		var character_transform: Transform = _character.transform
		var t := Transform(character_transform.basis, Vector3.ZERO)
		var next_look := direction.normalized() * -1
		t = t.looking_at(next_look, Vector3.UP).scaled(_character.scale)
		#var fps := min(1.0 / delta, 60.0)
		#var smooth_rot_correct : float = curve_smooth_rot.interpolate_baked(fps / 60.0)
		_character.transform = _character.transform.interpolate_with(t, min(10.0 * delta, 1.0))
		_forward_cast.rotation = _character.rotation
################################################################################
################################################################################
################################################################################

func _on_PlayerController_jump() -> void:
	on_jump()


func _on_PlayerController_jump_forward() -> void:
	on_jump_forward()

func _on_PlayerController_changed_direction(new_direction: Vector3) -> void:
	on_changed_direction(new_direction)



func _on_PlayerController_animation(num) -> void:
	on_start_animation_state(num)

func on_start_animation_state(anim: String) -> void :
	var anim_failed := false
	match anim :
		"Victory" :
			
			if _fcm.get_current_state() == FCM.SIT :
				_fcm.pop_state()
			
			_character.set_action_idx(VICTORY)
			_fcm.push_state(FCM.ACTION)
		"Sit" :
			if _fcm.get_current_state() == FCM.ACTION :
				_fcm.pop_state()
			_fcm.push_state(FCM.SIT)
		"Dance" :
			if _fcm.get_current_state() == FCM.SIT :
				_fcm.pop_state()
			_character.set_action_idx(DANCE_1)
			_fcm.push_state(FCM.ACTION)
		"Dance2" :
			if _fcm.get_current_state() == FCM.SIT :
				_fcm.pop_state()
			_character.set_action_idx(DANCE_2)
			_fcm.push_state(FCM.ACTION)
		"Wave" :
			if _fcm.get_current_state() == FCM.SIT :
				_fcm.pop_state()
			_character.set_action_idx(WAIVING)
			_fcm.push_state(FCM.ACTION)
		"Dodge" :
			if _fcm.get_current_state() == FCM.SIT :
				_fcm.pop_state()
			_character.set_action_idx(DANCE_2)
			_fcm.push_state(FCM.ACTION)
		_ :
			anim_failed = true
			push_warning("failed animation!")
	if not anim_failed:
		send_animation(anim)

func hide_model() -> void :
	_character.visible = !_character.visible


# network functions
func _send_all_data() -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	var name_pl : String = Singletones.get_GameSaveCloud().game_state.profile.get_name()
	var idx_char : int = Singletones.get_GameSaveCloud().game_state.current_charscter_idx
	var num_world : int = Singletones.get_GameSaveCloud().game_state.world_num
	var clothes : Array = Singletones.get_GameSaveCloud().game_state.character_customizer.get_list_reward_items(idx_char)
	var level_achiv : float = stepify(LevelColorConst.get_level_from_achiv_real(), 0.01)
	
	var is_active_sub := false
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree:
		if OS.get_name() == "Windows" and scene_tree.root.get_node_or_null("SteamManager") :
			is_active_sub = true
		else:
			var subs_checker :=  Singletones.get_SubsChecker()
			if subs_checker :
				is_active_sub = subs_checker.is_subs_active()
	_name_player.set_premium(is_active_sub)
	
	_data_network_all_data[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_all_data[NAME_DATA.NAME_PLAYER] = name_pl
	_data_network_all_data[NAME_DATA.CLOTHES] = clothes
	_data_network_all_data[NAME_DATA.IDX_CHARACTER] = idx_char
	_data_network_all_data[NAME_DATA.NUM_WORLD] = num_world
	_data_network_all_data[NAME_DATA.IN_GAME] = in_game
	_data_network_all_data[NAME_DATA.LEVEL_ACHIV] = level_achiv
	_data_network_all_data[NAME_DATA.IS_ACTIVE_SUB] = is_active_sub
	_data_network_all_data[NAME_DATA.IN_LOBBY] = in_lobby
	_data_network_all_data[NAME_DATA.IS_HOST] = is_host
	
	send_for_network_player(_data_network_all_data)
	send_for_network_player_in_game(_data_network_all_data)

func _send_give_me_all_data() -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	var key : int = NetworkConst.GLOBAL_TYPE_DATA.OPEN_GAME
	Singletones.get_Network().api.setup_data(key, _data_network_give_me_all_data)
	Singletones.get_Network().api.send_data_to_all()

func send_name_player() -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	var name_pl : String = Singletones.get_GameSaveCloud().game_state.profile.get_name()
	_data_network_name_player[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_name_player[NAME_DATA.NAME_PLAYER] = name_pl
	
	send_for_network_player(_data_network_name_player)
	send_for_network_player_in_game(_data_network_name_player)

func send_idx_character() -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	var idx_char : int = Singletones.get_GameSaveCloud().game_state.current_charscter_idx
	var clothes : Array = Singletones.get_GameSaveCloud().game_state.character_customizer.get_list_reward_items(idx_char)
	_data_network_idx_character[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_idx_character[NAME_DATA.IDX_CHARACTER] = idx_char
	_data_network_idx_character[NAME_DATA.CLOTHES] = clothes
	
	send_for_network_player(_data_network_idx_character)
	send_for_network_player_in_game(_data_network_idx_character)

func send_clothes() -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	var idx_char : int = Singletones.get_GameSaveCloud().game_state.current_charscter_idx
	var clothes : Array = Singletones.get_GameSaveCloud().game_state.character_customizer.get_list_reward_items(idx_char)
	_data_network_clothes[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_clothes[NAME_DATA.CLOTHES] = clothes
	
	send_for_network_player(_data_network_clothes)
	send_for_network_player_in_game(_data_network_clothes)

func send_num_world() -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	var num_world : int = Singletones.get_GameSaveCloud().game_state.world_num
	_data_network_num_world[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_num_world[NAME_DATA.NUM_WORLD] = num_world
	
	send_for_network_player(_data_network_num_world)
	send_for_network_player_in_game(_data_network_num_world)

func send_smile(smile: int) -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	_data_network_smile[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_smile[NAME_DATA.SMILE] = smile
	
	send_for_network_player(_data_network_smile)
	send_for_network_player_in_game(_data_network_smile)

func send_in_game(in_game_in: bool) -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	_data_network_in_game[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_in_game[NAME_DATA.IN_GAME] = in_game_in
	
	send_for_network_player(_data_network_in_game)
	send_for_network_player_in_game(_data_network_in_game)

func send_in_lobby(in_lobby_in: bool) -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	_data_network_in_lobby[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_in_lobby[NAME_DATA.IN_LOBBY] = in_lobby_in
	
	send_for_network_player(_data_network_in_lobby)
	send_for_network_player_in_game(_data_network_in_lobby)

func send_is_host(in_host_in: bool) -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	_data_network_is_host[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_is_host[NAME_DATA.IS_HOST] = in_host_in
	
	send_for_network_player(_data_network_is_host)
	send_for_network_player_in_game(_data_network_is_host)

func send_animation(anim: String) -> void :
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	
	_data_network_animation[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_animation[NAME_DATA.ANIMATION] = anim
	
	send_for_network_player(_data_network_animation)
	send_for_network_player_in_game(_data_network_animation)

func send_for_network_player(data_network: Dictionary) -> void :
	data_network[NAME_DATA.TYPE_UPDATE] = NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK
	var key : int = NetworkConst.GLOBAL_TYPE_DATA.OPEN_GAME
	Singletones.get_Network().api.setup_data(key, data_network)
	Singletones.get_Network().api.send_data_to_all()

func send_for_network_player_in_game(data_network: Dictionary) -> void :
	if not in_game and not in_lobby:
		return
	
	data_network[NAME_DATA.TYPE_UPDATE] = NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK_LEVEL
	var key : int = NetworkConst.GLOBAL_TYPE_DATA.OPEN_GAME
	Singletones.get_Network().api.setup_data(key, data_network)
	Singletones.get_Network().api.send_data_to_all()


func _on_TimerSavePosition_timeout():
	if not in_game and not in_lobby:
		if is_on_floor() :
			Singletones.get_GameSaveCloud().game_state.player_position = transform.origin



var _idx_timer := 0
func _on_TimerNetwork_timeout() -> void:
	if not _character:
		return
	if not is_instance_valid(_character):
		return
	if not Singletones.get_Network().api:
		return
	
	var step := 0.01
#	_data_network_move_player[NAME_DATA.MOVE_PLAYER] = PoolRealArray([
#		stepify(_character.global_transform.origin.x, step),
#		stepify(_character.global_transform.origin.y, step),
#		stepify(_character.global_transform.origin.z, step),
#	])
	_data_network_move_player[NAME_DATA.MOVE_PLAYER] = PoolRealArray([
		stepify(_prev_poses[0].x, step),
		stepify(_prev_poses[0].y, step),
		stepify(_prev_poses[0].z, step),
	])
	_data_network_move_player[NAME_DATA.TYPE_UPDATE] = NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK
	_data_network_move_player[NAME_DATA.IDX_OBJ] = int(name)
	var key : int = NetworkConst.GLOBAL_TYPE_DATA.OPEN_GAME
	Singletones.get_Network().api.setup_data(key, _data_network_move_player)
	Singletones.get_Network().api.send_data_to_all()
	
	if in_game or in_lobby:
		_data_network_move_player[NAME_DATA.MOVE_PLAYER] = PoolRealArray([
			stepify(_character.global_transform.origin.x, step),
			stepify(_character.global_transform.origin.y, step),
			stepify(_character.global_transform.origin.z, step),
		])
		_data_network_move_player[NAME_DATA.TYPE_UPDATE] = NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK_LEVEL
		Singletones.get_Network().api.setup_data(key, _data_network_move_player)
		Singletones.get_Network().api.send_data_to_all()
	
	_idx_timer += 1
	if _idx_timer > 5:
		_idx_timer = 0
		_send_all_data()


func wear_clothes_override(override: Array) -> void :
	if _character :
		_character.wear_clothes_override(override)

func wear_clothes_override_clear() -> void :
	if _character :
		_character.wear_clothes_override_clear()

