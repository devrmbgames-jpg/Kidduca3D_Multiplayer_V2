extends Reference
#class_name GameStateDailyGift

var last_datetime_day := 0
var last_day := 0
var reward_list := {}

static func get_current_datetime_day() -> int : 
	return get_datetime_day_from_unixtime(OS.get_unix_time())

static func get_datetime_day_from_unixtime(val: int) -> int :
	if val == 0 :
		return 0
	
	# warning-ignore:integer_division
	# warning-ignore:integer_division
	# warning-ignore:integer_division
	return val / 60 / 60 / 18

func to_dictionary() -> Dictionary :
	return {
		"last_datetime_day" : last_datetime_day,
		"last_day" : last_day,
		"reward_list" : reward_list
	}

func from_dictionary(dict: Dictionary) -> void :
	
	last_datetime_day = dict.get("last_datetime_day", 0)
	last_day = dict.get("last_day", 0)
	if dict.has("reward_list") :
		for key in dict.reward_list :
			reward_list[key as int] = bool(dict.reward_list[key] or reward_list.get(key as int, false))

func get_last_days() -> int :
	return last_day

func get_current_day() -> int :
	if last_datetime_day == 0 :
		return last_day
	
	if last_datetime_day > OS.get_unix_time() :
		last_datetime_day = 0
	
	
	
	if OS.get_unix_time() > last_datetime_day :
		if get_current_datetime_day() > get_datetime_day_from_unixtime(last_datetime_day) :
			return last_day + 1
	
	return last_day

func has_rewarded_from_day(day: int) -> bool :
	return reward_list.get(day, false)

func is_rewarded_current_day() -> bool :
	var day := get_current_day()
	var val: bool = reward_list.get(day, false)
	return val

func reward_current_day() -> void :
	if is_rewarded_current_day() :
		return
	
	reward_list[get_current_day()] = true
	last_day = get_current_day()
	last_datetime_day = OS.get_unix_time()
	
