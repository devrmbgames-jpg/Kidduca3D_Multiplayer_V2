extends Node

const IFirebaseMessage := preload("res://globals/singletones_v2/interfaces/IFirebaseMessage.gd")
const IGlobalGame := preload("res://globals/singletones_v2/interfaces/IGlobalGame.gd")
const INetwork := preload("res://globals/singletones_v2/interfaces/INetwork.gd")
const IRaycastInputManager := preload("res://globals/singletones_v2/interfaces/IRaycastInputManager.gd")
const IGameUiDelegate := preload("res://globals/singletones_v2/interfaces/IGameUiDelegate.gd")
const IGlobal := preload("res://globals/singletones_v2/interfaces/IGlobal.gd")
const IMusicManager := preload("res://globals/singletones_v2/interfaces/IMusicManager.gd")
const ILocalization := preload("res://globals/singletones_v2/interfaces/ILocalization.gd")
const IRaceSetup := preload("res://globals/singletones_v2/interfaces/IRaceSetup.gd")
const IGameSaveCloud := preload("res://globals/singletones_v2/interfaces/IGameSaveCloud.gd")
const IAchivment := preload("res://globals/singletones_v2/interfaces/IAchivment.gd")
const ISpotlight := preload("res://globals/singletones_v2/interfaces/ISpotlight.gd")
const ISoundInterface := preload("res://globals/singletones_v2/interfaces/ISoundInterface.gd")
const IMusicPlayer := preload("res://globals/singletones_v2/interfaces/IMusicPlayer.gd")
const ITimeCast := preload("res://globals/singletones_v2/interfaces/ITimeCast.gd")
const ISubsChecker := preload("res://globals/singletones_v2/interfaces/ISubsChecker.gd")
const ILearnSystem := preload("res://globals/singletones_v2/interfaces/ILearnSystem.gd")
const IPopupsManager := preload("res://globals/singletones_v2/interfaces/IPopupsManager.gd")
const ILocalizationSounds := preload("res://globals/singletones_v2/interfaces/ILocalizationSounds.gd")
const IEventHandler := preload("res://globals/singletones_v2/interfaces/IEventHandler.gd")
const IRateMe := preload("res://globals/singletones_v2/interfaces/iRateMe.gd")


enum SINGLETONES {
	FirebaseMessage,
	GlobalGame,
	Network,
	RaycastInputManager,
	GameUiDelegate,
	Global,
	MusicManager,
	Localization,
	RaceSetup,
	GameSaveCloud,
	Achivment,
	Spotlight,
	SoundInterface,
	MusicPlayer,
	TimeCast,
	SubsChecker,
	LearnSystem,
	PopupsManager,
	LocalizationSounds,
	EventHandler,
	RateMe,
}

const MAP := {
	SINGLETONES.FirebaseMessage : "res://globals/firebase/firebase_message.gd",
	SINGLETONES.GlobalGame : "res://globals/global_game.tscn",
	SINGLETONES.Network : "res://globals/network_global.gd",
	SINGLETONES.RaycastInputManager : "res://globals/drag_and_drop/raycast_input_manager.tscn",
	SINGLETONES.GameUiDelegate : "res://globals/game_ui_delegate.gd",
	SINGLETONES.Global : "res://globals/global.gd",
	SINGLETONES.MusicManager : "res://globals/music_manager/music_manager.tscn",
	SINGLETONES.Localization : "res://locale/localization.gd",
	SINGLETONES.RaceSetup : "res://globals/race_setup.gd",
	SINGLETONES.GameSaveCloud : "res://globals/game_save_cloud.tscn",
	SINGLETONES.Achivment : "res://globals/achivment.gd",
	SINGLETONES.Spotlight : "res://globals/spotlight/spotlight.gd",
	SINGLETONES.SoundInterface : "res://globals/sound_interface/sound_interface.tscn",
	SINGLETONES.MusicPlayer : "res://globals/music/music_player.tscn",
	SINGLETONES.TimeCast : "res://globals/time_cast/time_cast.gd",
	SINGLETONES.SubsChecker : "res://globals/godot_sk2/godot_sk2_subs_cheker.gd",
	SINGLETONES.LearnSystem : "res://globals/learn_system.gd",
	SINGLETONES.PopupsManager : "res://globals/popups_manager.gd",
	SINGLETONES.LocalizationSounds : "res://locale/locale_interface_sounds/localization_sounds.gd",
	SINGLETONES.EventHandler : "res://content/event_handler/event_handler.gd",
	SINGLETONES.RateMe : "res://globals/rate_me/rate_me.gd"
}

var _cache := {}

func _to_string() -> String:
	return "[Singletones]"

func instance_signletone(id: int) -> Node :
	var node: Node = _cache.get(id, null)
	if not node :
		if is_inside_tree() and is_instance_valid(self) :
			Logger.log_i(self, " ID:", id, " not found! create new singletone")
			var path : String = MAP[id]
			Logger.log_i(self, " path:", path)
			if ResourceLoader.exists(path) :
				Logger.log_i(self, " exists success!")
				var load_node = load(path)
				if load_node is PackedScene:
					node = load_node.instance()
				elif load_node is GDScript:
					node = load_node.new()
				_cache[id] = node
				node.name = path.get_file().capitalize()
				call_deferred("add_child", node, true)
				Logger.log_i(self, " instanced success!")
			else :
				Logger.log_w(self, "not found path: %s" %  path)
	return node


func get_FirebaseMessage() -> IFirebaseMessage :
	return instance_signletone(SINGLETONES.FirebaseMessage) as IFirebaseMessage

func get_GlobalGame() -> IGlobalGame :
	return instance_signletone(SINGLETONES.GlobalGame) as IGlobalGame

func get_Network() -> INetwork :
	return instance_signletone(SINGLETONES.Network) as INetwork

func get_RaycastInputManager() -> IRaycastInputManager :
	return instance_signletone(SINGLETONES.RaycastInputManager) as IRaycastInputManager

func get_GameUiDelegate() -> IGameUiDelegate :
	return instance_signletone(SINGLETONES.GameUiDelegate) as IGameUiDelegate

func get_Global() -> IGlobal :
	return instance_signletone(SINGLETONES.Global) as IGlobal

func get_MusicManager() -> IMusicManager :
	return instance_signletone(SINGLETONES.MusicManager) as IMusicManager

func get_Localization() -> ILocalization :
	return instance_signletone(SINGLETONES.Localization) as ILocalization

func get_RaceSetup() -> IRaceSetup :
	return instance_signletone(SINGLETONES.RaceSetup) as IRaceSetup

func get_RateMe() -> IRateMe :
	return instance_signletone(SINGLETONES.RateMe) as IRateMe

func get_GameSaveCloud() -> IGameSaveCloud :
	return instance_signletone(SINGLETONES.GameSaveCloud) as IGameSaveCloud

func get_Achivment() -> IAchivment :
	return instance_signletone(SINGLETONES.Achivment) as IAchivment

func get_Spotlight() -> ISpotlight :
	return instance_signletone(SINGLETONES.Spotlight) as ISpotlight

func get_SoundInterface() -> ISoundInterface :
	return instance_signletone(SINGLETONES.SoundInterface) as ISoundInterface

func get_MusicPlayer() -> IMusicPlayer :
	return instance_signletone(SINGLETONES.MusicPlayer) as IMusicPlayer

func get_TimeCast() -> ITimeCast :
	return instance_signletone(SINGLETONES.TimeCast) as ITimeCast

func get_SubsChecker() -> ISubsChecker :
	return instance_signletone(SINGLETONES.SubsChecker) as ISubsChecker


func get_LearnSystem() -> ILearnSystem :
	return instance_signletone(SINGLETONES.LearnSystem) as ILearnSystem

func get_PopupsManager() -> IPopupsManager :
	return instance_signletone(SINGLETONES.PopupsManager) as IPopupsManager

func get_LocaleSounds() -> ILocalizationSounds :
	return instance_signletone(SINGLETONES.LocalizationSounds) as ILocalizationSounds

func get_EventHandler() -> IEventHandler :
	return instance_signletone(SINGLETONES.EventHandler) as IEventHandler

func init_singletones() -> void :
	Logger.log_i(self, " Singletones start init")
	
	QueueCall.push_call(self, "get_GlobalGame")
	Logger.log_i(self, " GlobalGame inited")
	
	QueueCall.push_call(self, "get_Network")
	Logger.log_i(self, " Network inited")
	
	QueueCall.push_call(self, "get_RaycastInputManager")
	Logger.log_i(self, " RaycastInputManager inited")
	
	QueueCall.push_call(self, "get_GameUiDelegate")
	Logger.log_i(self, " GameUiDelegate inited")
	
	QueueCall.push_call(self, "get_Global")
	Logger.log_i(self, " Global inited")
	
	QueueCall.push_call(self, "get_MusicManager")
	Logger.log_i(self, " MusicManager inited")
	
	QueueCall.push_call(self, "get_Localization")
	Logger.log_i(self, " Localization inited")
	
	QueueCall.push_call(self, "get_Spotlight")
	Logger.log_i(self, " Spotlight inited")
	
	QueueCall.push_call(self, "get_FirebaseMessage")
	Logger.log_i(self, " FirebaseMessage inited")
	
	QueueCall.push_call(self, "get_SoundInterface")
	Logger.log_i(self, " SoundInterface inited")
	
	QueueCall.push_call(self, "get_MusicPlayer")
	Logger.log_i(self, " MusicPlayer inited")
	
	QueueCall.push_call(self, "get_GameSaveCloud")
	Logger.log_i(self, " GameSaveCloud inited")
	
	QueueCall.push_call(self, "get_RaceSetup")
	Logger.log_i(self, " RaceSetup inited")
	
	QueueCall.push_call(self, "get_Achivment")
	Logger.log_i(self, " Achivment inited")
	
	QueueCall.push_call(self, "get_TimeCast")
	Logger.log_i(self, " TimeCast inited")
	
	QueueCall.push_call(self, "get_SubsChecker")
	Logger.log_i(self, " SubsCheker inited")
	
	QueueCall.push_call(self, "get_EventHandler")
	Logger.log_i(self, " EventHandler inited")
	
	get_LearnSystem()
	Logger.log_i(self, " LearnSystem inited")
	
	get_LocaleSounds()
	Logger.log_i(self, " LocalizationSounds inited")
	
	QueueCall.push_call(self, "get_RateMe")
	Logger.log_i(self, " RateMe inited")

