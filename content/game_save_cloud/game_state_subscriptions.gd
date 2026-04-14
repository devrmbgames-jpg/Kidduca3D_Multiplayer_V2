extends Reference

var subscriptions := {}
var activated_free_days := false

func push_subscription(key: String, days_sub: float) :
	activated_free_days = true
	var timeout : int = OS.get_unix_time() + int(days_sub * 24 * 60 * 60)
	subscriptions[key] = str(timeout)

func push_free_days(key: String, days_sub: float) -> void :
	if not activated_free_days:
		push_subscription(key, days_sub)

func get_max_unix_timeout() -> int :
	var timeout := 0
	for time in subscriptions.values():
		var time_int : int = time as int
		timeout = max(timeout, time_int) as int
	return timeout

func is_timeout() -> bool :
	var timeout_max : int = get_max_unix_timeout()
	return timeout_max < OS.get_unix_time()

func to_dictionary() -> Dictionary :
	return {
		"subs" : subscriptions,
		"activ_free_days" : activated_free_days
	}

func from_dictionary(dict: Dictionary) :
	var subs_dict : Dictionary = dict.subs
	for key in subs_dict :
		var timeout_sub : int = subscriptions.get(key, "0") as int
		var timeout_dict : int = subs_dict[key] as int
		subscriptions[key] = str(max(timeout_sub, timeout_dict))
	activated_free_days = activated_free_days or dict.activ_free_days
