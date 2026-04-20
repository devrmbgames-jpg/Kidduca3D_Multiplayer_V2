extends Reference
#class_name CharactersConsts

const LIST_PATH := [
	"res://resources/models/character_v2/full/dog/dog_player.tscn",
	"res://resources/models/character_v2/full/kitty/kitty_player.tscn",
	"res://resources/models/character_v2/full/pig/pig_player.tscn",
	"res://resources/models/character_v2/full/panda/panda_player.tscn",
	"res://resources/models/character_v2/full/heron/heron_player.tscn",
	"res://resources/models/character_v2/full/rabbit/rabbit_player.tscn",
	"res://resources/models/character_v2/full/hair_ball/hair_ball_player.tscn"
]

const NAMES := [
	"Friendly Dog",
	"Glamorous Kitty",
	"Funny Pig",
	"Cool Panda",
	"Clever Heron",
	"Cute Rabbi",
	"Fluffy Chick",
	
]

# old
#const ICONS := [
#	"res://resources/character_icons/dog.png",
#	"res://resources/character_icons/cat_rocket.png",
#	"res://resources/character_icons/Pig.png",
#	"res://resources/character_icons/panda_rocket.png",
#	"res://resources/character_icons/heron_rocket.png",
#	"res://resources/character_icons/rabbit_2.png",
#	"res://resources/character_icons/hairy_ball_rocket.png"
#]

const ICONS := [
	"res://resources/character_icons/avatars/dog.png",
	"res://resources/character_icons/avatars/cat.png",
	"res://resources/character_icons/avatars/pig.png",
	"res://resources/character_icons/avatars/panda.png",
	"res://resources/character_icons/avatars/heron.png",
	"res://resources/character_icons/avatars/rabbit.png",
	"res://resources/character_icons/avatars/crazy.png"
]

const COLOR_BG_ICON := [
	Color("3690ec"),
	Color("f03f3f"),
	Color("669933"),
	Color("f03f3f"),
	Color("a766f6"),
	Color("3690ec"),
	Color("d730e1"),
]

const PRICES := [
	9, # dog
	9, # cat
	9, # pig
	9, # panda
	9, # heron
	9, # rabbit
	9  # hairy ball
]


const BotNames := [
	"SunnyBunny",
	"HappyPaws",
	"FrostyBear",
	"SpeedyTurtle",
	"SillyKitty",
	"StarrySky",
	"MagicBubbles",
	"JellyBean",
	"GigglyPanda",
	"JasonFun",
	"LoganLion",
	"TinyRainbow",
	"BubblePop",
	"ThunderPuff",
	"EthanJoy",
	"WigglyWorm",
	"TylerSmiles",
	"HappyDino",
	"ConnorTiger",
	"BouncyFrog",
	"CuddlyKoala",
	"BrandonBear",
	"GummyShark",
	"LollipopStar",
	"NathanSpark",
	"GiggleMonster",
	"FireflyGlow",
	"Marshmallow",
	"AustinBubbles",
	"TwinkleToes",
	"DoodleBug",
	"DylanSunny",
	"ZippyZebra",
	"SnappyTurtle",
	"FluffyBunny",
	"CuddlyPuppy",
	"RyanRocket",
	"SqueezyPeach",
	"CalebPanda",
	"WaffleSprout",
	"JollyMonkey",
	"JacobSmiley",
	"CupcakeZoom",
	"TootsieTiger",
	"MasonBumble",
	"GummyGiggles",
	"WigglyPanda",
	"LiamHug",
	"CheekyChipmunk",
	"BouncySprout",
	"PuddingPaws",
	"JumpyLlama",
	"NoahZoom",
	"SnuggleDuck",
	"RainbowRacer",
	"PoppyToad",
	"SillyGiggles",
	"ZacharySprout",
	"TippyTiger",
	"SqueakyMouse",
	"DoodleDaisy",
	"CarterZippy",
	"JollyKangaroo",
	"BuzzyBee",
	"HunterSunny",
	"WigglesWoof",
	"FuzzyBubbles",
	"ElijahCupcake",
	"CloudyKitten",
	"TinkerBear",
	"ChocoBunny",
	"WyattHug",
	"SprinklesJoy",
	"OwenPudding",
	"StarryKitten",
	"GoofyPaws",
	"SnappyFox",
	"JumpyJelly",
	"WobblyPenguin",
	"ZoomyCheetah",
	"FluffyLamb",
	"ColtonSnuggles",
	"TippyToad",
	"PuddingKitty",
	"WigglyHedgehog",
	"CupcakeBunny",
	"LandonHoppy",
	"FuzzyBear",
	"SmileyStar",
	"IsaacChoco",
	"TwinkleLamb",
	"SnappyHug",
	"JumpyCupcake",
	"SqueezyBear",
	"EvanBouncy",
	"DizzyMonkey",
	"JordanGiggles",
	"WobblyBubbles",
	"TinyRainbow",
	"JellyWiggles",
]

static func get_random_icon_path() -> String :
	return ICONS[randi() % ICONS.size()]

static func get_character_path(idx: int) -> String :
	if idx < 0 or idx >= LIST_PATH.size():
		return LIST_PATH[0]
	return LIST_PATH[idx]
