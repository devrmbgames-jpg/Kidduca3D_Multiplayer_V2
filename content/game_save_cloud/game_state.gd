extends Reference
#class_name GameState

const CarConst := preload("res://content/vehicle/car_const.gd")

const GAME_ATTRIBUTE := preload("res://content/achivment/game_attribute.gd")
const GAME_STATE_BUILDING := preload("res://content/game_save_cloud/game_state_building.gd")
const GAME_STATE_COINS := preload("res://content/game_save_cloud/game_state_coins.gd")
const GAME_STATE_ACHIVMENT := preload("res://content/game_save_cloud/game_state_achivment.gd")
const GAME_STATE_CHARACTER := preload("res://content/game_save_cloud/game_state_character.gd")
const GAME_STATE_COLORING := preload("res://content/game_save_cloud/game_state_coloring.gd")
const GAME_STATE_DRESS := preload("res://content/game_save_cloud/game_state_dress.gd")
const GAME_STATE_SCALES_ITEMS := preload("res://content/game_save_cloud/game_state_scales_items.gd")
const GAME_STATE_BUILD_NOTIFICATION := preload("res://content/game_save_cloud/game_state_build_notifications.gd")
const GAME_STATE_PURCHASED_GAMES := preload("res://content/game_save_cloud/game_state_purchased_games.gd")
const GAME_STATE_REWARD_ITEMS := preload("res://content/game_save_cloud/game_state_reward_items.gd")
const GAME_STATE_CHARACTER_CUSTOMIZER := preload("res://content/game_save_cloud/game_state_character_customizer.gd")
const GAME_STATE_DAILY_GIFT := preload("res://content/game_save_cloud/game_state_daily_gift.gd")
const GAME_STATE_SUBSCRIPTIONS := preload("res://content/game_save_cloud/game_state_subscriptions.gd")
const GAME_STATE_PROFILE := preload("res://content/game_save_cloud/game_state_profile.gd")
const GAME_STATE_LEARN_LEVELS := preload("res://content/game_save_cloud/game_state_learn_levels.gd")
const GAME_STATE_BUILD := preload("res://content/game_save_cloud/game_save_cloud_build_item.gd")

const GAME_STATE_CARS := preload("res://content/game_save_cloud/game_state_cars.gd")
const GAME_STATE_COINS_CAR := preload("res://content/game_save_cloud/game_state_coins_car.gd")
const GAME_STATE_TRACKS := preload("res://content/game_save_cloud/game_state_tracks.gd")

const GAME_STATE_PUZZLES := preload("res://content/game_save_cloud/game_state_puzzles.gd")

const VALIDATE_VERSION := 0

var rmb_coin: GAME_ATTRIBUTE = GAME_ATTRIBUTE.new()
var rmb_pack: GAME_ATTRIBUTE = GAME_ATTRIBUTE.new()

var building: GAME_STATE_BUILDING = GAME_STATE_BUILDING.new()
var player_position: Vector3 = Vector3.ZERO

var rmb_coins_objects: GAME_STATE_COINS = GAME_STATE_COINS.new()
var achivment: GAME_STATE_ACHIVMENT = GAME_STATE_ACHIVMENT.new()
var character: GAME_STATE_CHARACTER = GAME_STATE_CHARACTER.new()
var current_charscter_idx := 0
var coloring: GAME_STATE_COLORING = GAME_STATE_COLORING.new()
var dress: GAME_STATE_DRESS = GAME_STATE_DRESS.new()
var scales_items : GAME_STATE_SCALES_ITEMS = GAME_STATE_SCALES_ITEMS.new()
var build_notif_need_show : GAME_STATE_BUILD_NOTIFICATION = GAME_STATE_BUILD_NOTIFICATION.new()

var purchased_games : GAME_STATE_PURCHASED_GAMES = GAME_STATE_PURCHASED_GAMES.new()

var reward_items : GAME_STATE_REWARD_ITEMS = GAME_STATE_REWARD_ITEMS.new()
var character_customizer : GAME_STATE_CHARACTER_CUSTOMIZER = GAME_STATE_CHARACTER_CUSTOMIZER.new()

var daily_gifts : GAME_STATE_DAILY_GIFT = GAME_STATE_DAILY_GIFT.new()

var subscriprions : GAME_STATE_SUBSCRIPTIONS = GAME_STATE_SUBSCRIPTIONS.new()

var profile : GAME_STATE_PROFILE = GAME_STATE_PROFILE.new()
var completed_levels : GAME_STATE_LEARN_LEVELS = GAME_STATE_LEARN_LEVELS.new()

var puzzles : GAME_STATE_PUZZLES = GAME_STATE_PUZZLES.new()

var last_day_play_demo_cargames := 0

var experience := 0
var world_num := 1

var total_play_time := 0.0

# cars
var v2_cars_state: GAME_STATE_CARS = GAME_STATE_CARS.new()
var coins_car : GAME_STATE_COINS_CAR = GAME_STATE_COINS_CAR.new()
var tracks: GAME_STATE_TRACKS = GAME_STATE_TRACKS.new()

var build_home: GAME_STATE_BUILD = GAME_STATE_BUILD.new()
var build_home_entered := false


# football
var id_team := 0

func to_dictionary() -> Dictionary :
	return {
		"version" : VALIDATE_VERSION,
		"rmb_coin" : rmb_coin.to_dictionary(),
		"rmb_pack" : rmb_pack.to_dictionary(),
		"building" : building.to_dictionary(),
		"player_position" : player_position,
		"rmb_coins_objects" : rmb_coins_objects.to_dictionary(),
		"achivment" : achivment.to_array(),
		"experience" : experience,
		"character" : character.to_array(),
		"current_charscter_idx" : current_charscter_idx,
		"coloring" : coloring.to_array(),
		"world_num" : world_num,
		"cloth_inventory" : dress.to_array_cloth_inventory(),
		"cloth_released" : dress.to_array_cloth_released(),
		"scales_items" : scales_items.to_array(),
		#"build_notification_need_show" : build_notif_need_show.to_dictionary(),
		"purchased_games" : purchased_games.to_array(),
		"reward_items" : reward_items.to_dictionary(),
		"character_customizer" : character_customizer.to_dictionary(),
		"daily_gifts" : daily_gifts.to_dictionary(),
		"last_day_play_demo_cargames" : last_day_play_demo_cargames,
		"subscriprions" : subscriprions.to_dictionary(),
		"profile" : profile.to_dictionary(),
		"completed_levels" : completed_levels.to_dictionary(),
		"puzzles" : puzzles.to_array(),
		# cars
		"v2_cars_state" : v2_cars_state.to_dictionary(),
		"coins_car" : coins_car.to_dictionary(),
		"tracks" : tracks.to_array(),
		"build_home" : build_home.to_dict(),
		"build_home_entered" : build_home_entered,
		"total_play_time" : total_play_time
	}

func from_dictionary(dict: Dictionary) -> void :
	
	if dict.has("rmb_coin"):
		rmb_coin.from_dictionary(dict["rmb_coin"] as Dictionary)
	if dict.has("rmb_pack"):
		rmb_pack.from_dictionary(dict["rmb_pack"] as Dictionary)
	if dict.has("building"):
		building.from_dictionary(dict["building"] as Dictionary)
	if dict.has("build_home") :
		build_home.from_dict(dict["build_home"] as Dictionary)
	
	#player_position = dict.player_position as Vector3
	if dict.has("player_position") :
		if dict.get("player_position", Vector3.ZERO) is Vector3 :
			player_position = dict.get("player_position", Vector3.ZERO) as Vector3
		else:
			var str_vec := dict.get("player_position", "(0.0,0.0,0.0)") as String
			if str_vec :
				player_position = _str_to_vector3(str_vec)
			else :
				player_position = Vector3.ZERO
	
	if dict.has("rmb_coins_objects"):
		rmb_coins_objects.from_dictionary(dict["rmb_coins_objects"] as Dictionary)
	if dict.has("achivment"):
		achivment.from_array(dict["achivment"] as Array)
	if dict.has("experience"):
		experience = dict["experience"] as int
	if dict.has("world_num"):
		world_num = dict["world_num"] as int
	if dict.has("character"):
		character.from_array(dict["character"] as Array)
	if dict.has("current_charscter_idx"):
		current_charscter_idx = dict["current_charscter_idx"] as int
	if dict.has("coloring"):
		coloring.from_array(dict["coloring"] as Array)
	if dict.has("cloth_inventory"):
		dress.from_array_cloth_inventory(dict["cloth_inventory"] as Array)
	if dict.has("cloth_released"):
		dress.from_array_cloth_released(dict["cloth_released"] as Array)
	if dict.has("scales_items"):
		scales_items.from_array(dict["scales_items"] as Array)
	
	#build_notif_need_show.from_dictionary(dict.get("build_notification_need_show", {}) as Dictionary)
	
	if dict.has("purchased_games"):
		purchased_games.from_array(dict["purchased_games"] as Array)
	if dict.has("reward_items"):
		reward_items.from_dictionary(dict["reward_items"] as Dictionary)
	if dict.has("character_customizer"):
		character_customizer.from_dictionary(dict["character_customizer"] as Dictionary)
	if dict.has("daily_gifts"):
		daily_gifts.from_dictionary(dict["daily_gifts"] as Dictionary)
	if dict.has("last_day_play_demo_cargames"):
		last_day_play_demo_cargames = dict["last_day_play_demo_cargames"] as int
	if dict.has("subscriprions"):
		subscriprions.from_dictionary(dict["subscriprions"] as Dictionary)
	if dict.has("profile"):
		profile.from_dictionary(dict["profile"] as Dictionary)
	if dict.has("completed_levels"):
		completed_levels.from_dictionary(dict["completed_levels"] as Dictionary)
	if dict.has("puzzles"):
		puzzles.from_array(dict["puzzles"] as Array)
	
	#VERSION 2 cars
	if dict.has("v2_cars_state"):
		v2_cars_state.from_dictionary(dict["v2_cars_state"] as Dictionary)
	if dict.has("coins_car"):
		coins_car.from_dictionary(dict["coins_car"] as Dictionary)
	if dict.has("tracks"):
		tracks.from_array(dict["tracks"] as Array)
	
	if dict.has("total_play_time") :
		total_play_time = dict["total_play_time"] as float
	
#	if dict.has("build_home_entered") :
#		build_home_entered = dict.get("build_home_entered", false)

func _str_to_vector3(string : String) -> Vector3 :
	var arr := string.lstrip("(").split_floats(",")
	if arr.size() >= 3:
		var vec := Vector3(arr[0], arr[1], arr[2])
		return vec
	return Vector3.ZERO

func reset_all() -> void :
	rmb_coin.value_cost = 0
	rmb_coin.value_take = 0
	rmb_coin.value_buy = 0
	
	rmb_pack.value_cost = 0
	rmb_pack.value_take = 0
	rmb_pack.value_buy = 0
	
	
	building.building_list = {}
	rmb_coins_objects.coins = {}
	achivment.achivment_list = []
	experience = 0
	
	world_num = 0
	
	character.character_list = [0, 1]
	current_charscter_idx = 0
	coloring.coloring_list = []
	
	player_position = Vector3.ZERO
	
	dress.cloth_inventory_list = []
	dress.cloth_released_list = []
	
	scales_items.scales_items_list = []
	
	build_notif_need_show.build_notifications_list = {}
	
	purchased_games.purchased_games_list = []
	
	reward_items.reward_items = {}
	character_customizer.characters_custom = {}
	
	last_day_play_demo_cargames = 0
	
	subscriprions.subscriptions = {}
	subscriprions.activated_free_days = false
	
	profile.reset_profile()
	completed_levels.completed_levels = {}
	
	puzzles.puzzles = []
	
	#VERSION 2 cars
	v2_cars_state.car_current = 0
	v2_cars_state.car_open = {}
	v2_cars_state.push_car(CarConst.TYPE_CAR.OLD)
	
	coins_car.value_take = 0
	coins_car.value_cost = 0
	
	tracks.tracks_list = []
	
	total_play_time = 0.0
	
	build_home_entered = false
	
	build_home.reset()

