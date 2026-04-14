extends Reference
#class_name GameBuildNotificationsNeedShow

var build_notifications_list := {}

func push_build_notification(build_notif: String) -> void :
	if not build_notifications_list.has(build_notif) :
		build_notifications_list[build_notif] = 1

func disable_build_notification(build_notif: String) -> void :
	if build_notifications_list.has(build_notif):
		build_notifications_list[build_notif] = 0

func need_show_build_notification(build_notif: String) -> bool :
	if build_notifications_list.has(build_notif):
		if build_notifications_list[build_notif] as int == 1:
			return true
		else:
			return false
	else:
		return false

func has_build_notification(build_notif: String) -> bool :
	return build_notifications_list.has(build_notif)

func to_dictionary() -> Dictionary :
	return build_notifications_list

func from_dictionary(from: Dictionary) -> void :
	build_notifications_list = from
