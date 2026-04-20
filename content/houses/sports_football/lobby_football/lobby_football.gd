extends Spatial

const NetworkConst := preload("res://content/network/network_const.gd")

const NETWORK_PLAYER_PATH := "res://content/character/player_network.tscn"
const NETWORK_PLAYER := preload("res://content/character/player_network.gd")

const TEAM_MARK_PATH := "res://content/houses/sports_football/team_marker.tscn"
const TEAM_MARK := preload("res://content/houses/sports_football/team_marker.gd")

const ENEMY_TR := preload("res://content/Enemy/enemy_multiplayer/enemy_multiplayer.gd")

const LEVEL_FOOTBALL_PATH := "res://content/houses/sports_football/football_mp/sports_football_mp.tscn"

# Maximum number of human players in a football match (5v5 = 10 players)
const MAX_FOOTBALL_PLAYERS := 10

onready var _network_players := $NetworkPlayers
onready var _team_marks := $TeamMarks
onready var _label_timer_lobby := $TimerLobby/LabelTimer

onready var _pos_start := $PosStart
onready var _pos_spawn_level := $PosSpawnLevel

enum NAME_DATA {
	TYPE_UPDATE,
	TYPE,
	IDX_OBJ,
	TYPE_OBJ,
}


var team_mark_pl : TEAM_MARK = null
var game = null

# --- FIX: Track whether the football game instance has already been created ---
var _is_game_started := false


func start_game() -> void :
	var player = Singletones.get_Global().player_character
	player.global_position = _pos_start.global_position
	player.freez = false
	player.enabled = true
	Singletones.get_GameUiDelegate().share.controler.rotation.y = -PI
	
	var team_mark : TEAM_MARK = ResourceLoader.load(TEAM_MARK_PATH, "", true).instance()
	team_mark.name = player.name
	_team_marks.add_child(team_mark)
	team_mark.player = player
	team_mark.set_side_team(randi() % TEAM_MARK.COLOR_TEAM.size())
	team_mark_pl = team_mark
	
	Singletones.get_GameUiDelegate().share.is_pause_in_popup_close = false


func exit() -> void :
	if game and is_instance_valid(game):
		game.exit()
	_is_game_started = false
	queue_free()
	
	var player = Singletones.get_Global().player_character
	player.wear_clothes_override_clear()

func _exit_out_game() -> void :
	Singletones.get_GameUiDelegate().share.emit_signal("close")


func connect_signal_timer_lobby(enemy_trigger: ENEMY_TR) -> void :
	if not enemy_trigger:
		return
	if not is_instance_valid(enemy_trigger):
		return
	
	if not enemy_trigger.is_connected("timer_tick", self, "_EnemyTrigger_timer_tick"):
		enemy_trigger.connect("timer_tick", self, "_EnemyTrigger_timer_tick")
	if not enemy_trigger.is_connected("timer_timeout", self, "_EnemyTrigger_timer_timeout"):
		enemy_trigger.connect("timer_timeout", self, "_EnemyTrigger_timer_timeout")


# --- FIX: Check if the current session's football match is full ---
# Returns the total number of human players currently in the football lobby/game.
func get_current_player_count() -> int :
	var count := 1  # count the local player
	if _network_players and is_instance_valid(_network_players):
		count += _network_players.get_child_count()
	return count


# --- FIX: Called externally to check if a new player can join this match ---
func is_football_full() -> bool :
	return get_current_player_count() >= MAX_FOOTBALL_PLAYERS


# --- FIX: Allow a late-joining player to join the already-running football game ---
func try_join_existing_game() -> bool :
	# If the game hasn't started yet, the player will naturally join via the timer.
	if not _is_game_started:
		return false
	
	if not game or not is_instance_valid(game):
		return false
	
	if is_football_full():
		return false
	
	# The player is already in the lobby scene (network players are synced).
	# We just need to make sure the game node knows about them.
	# The network data flow (update_network_data) already handles adding
	# new network players dynamically, so this should work transparently.
	Logger.log_i(self, " Late join: player joining existing football game")
	return true


func update_network_data(data: Dictionary) -> void :
	match data[NAME_DATA.TYPE_UPDATE] as int:
		NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_PLAYER_NETWORK_LEVEL:
			var path : String = "NetworkPlayers/"
			if not has_node(path + str(data[NAME_DATA.IDX_OBJ])):
				var path_dog := "res://content/character/player_network.tscn"
				var dog = ResourceLoader.load(path_dog, "", true).instance()
				dog.name = str(data[NAME_DATA.IDX_OBJ])
				dog.is_player_in_game = true
				dog.is_visible = true
				_network_players.add_child(dog)
				var team_mark : TEAM_MARK = ResourceLoader.load(TEAM_MARK_PATH, "", true).instance()
				team_mark.name = str(data[NAME_DATA.IDX_OBJ])
				_team_marks.add_child(team_mark)
				team_mark.player = dog
				dog.connect("tree_exited", team_mark, "queue_free")
			else:
				var player_network = get_node(path + str(data[NAME_DATA.IDX_OBJ]))
				if is_instance_valid(player_network):
					if player_network.has_method("update_network_data"):
						player_network.update_network_data(data)
		NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_LEVELS:
			match data[NAME_DATA.TYPE_OBJ] as int:
				NetworkConst.TYPE_OBJ_LEVEL.FOOTBALL_TEAM_MARK:
					var path : String = "TeamMarks/"
					var path_full : String = path + str(data[NAME_DATA.IDX_OBJ])
					if has_node(path_full):
						var team_mark = get_node(path_full)
						if is_instance_valid(team_mark):
							if team_mark.has_method("update_network_data"):
								team_mark.update_network_data(data)
				NetworkConst.TYPE_OBJ_LEVEL.FOOTBALL_BALL, \
				NetworkConst.TYPE_OBJ_LEVEL.FOOTBALL_GAME, \
				NetworkConst.TYPE_OBJ_LEVEL.FOOTBALL_BOT:
					if game and is_instance_valid(game):
						if game.has_method("update_network_data"):
							game.update_network_data(data)




func _EnemyTrigger_timer_tick(sec: int) -> void :
	_label_timer_lobby.text = str(sec) + "s"

func _EnemyTrigger_timer_timeout() -> void :
	# --- FIX: Guard against creating a duplicate football game instance ---
	if _is_game_started:
		Logger.log_i(self, " Football game already started, ignoring duplicate timer_timeout")
		return
	
	_is_game_started = true
	
	for npl in _network_players.get_children():
		npl.in_lobby = false
		npl.in_game = true
	
	game = ResourceLoader.load(LEVEL_FOOTBALL_PATH, "", true).instance()
	game.name = "Football"
	add_child(game)
	game.global_position = _pos_spawn_level.global_position
	if team_mark_pl and is_instance_valid(team_mark_pl):
		game.team_color = team_mark_pl.color_team
	game.network_players_lobby = _network_players
	game.team_marks_lobby = _team_marks
	game.name_node_lobby = name
	game.start_game()
	
	Singletones.get_Global().setup_visible_hints_inside_game()


func _on_AreaEnteredTriggerRed_body_entered(_body: Node) -> void:
	if not team_mark_pl:
		return
	if not is_instance_valid(team_mark_pl):
		return
	
	team_mark_pl.set_side_team(TEAM_MARK.COLOR_TEAM.RED)


func _on_AreaEnteredTriggerBlue_body_entered(_body: Node) -> void:
	if not team_mark_pl:
		return
	if not is_instance_valid(team_mark_pl):
		return
	
	team_mark_pl.set_side_team(TEAM_MARK.COLOR_TEAM.BLUE)
