extends Spatial

const NetworkConst := preload("res://content/network/network_const.gd")
const RewardItemsConst := preload("res://content/ui/reward_items/reward_items_const.gd")

const PLAYER = preload("res://content/character/character_v2.gd")
const PLAYER_NETWORK = preload("res://content/character/player_network.gd")

onready var _sprite_mark := $SpriteMarker
onready var _marker := $"%Marker" as Spatial

enum COLOR_TEAM {
	RED,
	BLUE
}

var _color_mark := {
	COLOR_TEAM.RED : Color.red,
	COLOR_TEAM.BLUE : Color.blue
}


var player : Spatial = null
var color_team := 0


# network
enum TYPE_DATA {
	COLOR_TEAM
}

enum NAME_DATA {
	TYPE_UPDATE,
	TYPE,
	IDX_OBJ,
	TYPE_OBJ,
	
	COLOR_TEAM
}

var _data_network_color := {
	NAME_DATA.TYPE_UPDATE : NetworkConst.TYPE_DATA_OPEN_GAME.UPDATE_OG_LEVELS,
	NAME_DATA.TYPE : TYPE_DATA.COLOR_TEAM,
	NAME_DATA.IDX_OBJ : 0,
	NAME_DATA.TYPE_OBJ : NetworkConst.TYPE_OBJ_LEVEL.FOOTBALL_TEAM_MARK,
	NAME_DATA.COLOR_TEAM : 0
}



func _process(_delta: float) -> void:
	if not player:
		return
	if not is_instance_valid(player):
		return
	
	if player is PLAYER:
		global_position = player.get_character().global_position
		
		var node := get_tree().get_first_node_in_group("MP_BALL")
		if node :
			var ball := node as Spatial
			var to := ball.global_position as Vector3
			
			var distance := ball.global_position.distance_to(global_position)
			if distance > 1.0 :
				to.y = _marker.global_position.y
				_marker.visible = true
				_marker.look_at(to, Vector3.UP)
			else :
				_marker.visible = false
		else :
			_marker.visible = false
		
	elif player is PLAYER_NETWORK:
		global_position = player.get_pos_network_player()
	else:
		global_position = player.global_position
	
	

func is_player() -> bool :
	return player is PLAYER

func set_side_team(color: int) -> void :
	if color < 0:
		color = 0
	if color > COLOR_TEAM.size() - 1:
		color = COLOR_TEAM.size() - 1
	
	color_team = color
	_sprite_mark.modulate = _color_mark.get(color, Color.yellow)
	_sprite_mark.modulate.a = 0.5
	
	if player and player.has_method("wear_clothes_override") :
		if color == COLOR_TEAM.RED :
			player.wear_clothes_override(RewardItemsConst.FOOTBALL_RED)
		else :
			player.wear_clothes_override(RewardItemsConst.FOOTBALL_BLUE)
	
	send_color()



func send_color() -> void :
	if not is_player():
		return
	
	_data_network_color[NAME_DATA.IDX_OBJ] = int(name)
	_data_network_color[NAME_DATA.COLOR_TEAM] = color_team
	var key : int = NetworkConst.GLOBAL_TYPE_DATA.OPEN_GAME
	Singletones.get_Network().api.setup_data(key, _data_network_color)
	Singletones.get_Network().api.send_data_to_all()

func update_network_data(data: Dictionary) -> void :
	if is_player():
		return
	
	match data[NAME_DATA.TYPE] as int:
		TYPE_DATA.COLOR_TEAM:
			set_side_team(data.get(NAME_DATA.COLOR_TEAM, COLOR_TEAM.RED) as bool)


func _on_TimerUpdateNetwork_timeout() -> void:
	send_color()


