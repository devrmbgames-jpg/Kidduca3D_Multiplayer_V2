extends Reference
#class_name GameStateTracks

var tracks_list := []

func push_track(track: Dictionary) -> void :
	tracks_list.append(track)

func push_is_old(idx: int) -> void :
	if has_track(idx):
		var track : Dictionary = tracks_list[idx]
		if track.has("is_new"):
			track.is_new = false

func has_track(idx: int) -> bool :
	if idx < tracks_list.size():
		return true
	else:
		return false

func get_tracks() -> Array :
	return tracks_list

func get_track(idx: int) -> Dictionary :
	if idx < tracks_list.size():
		return tracks_list[idx]
	else:
		return {}

func remove_track(idx: int) -> void :
	if has_track(idx):
		tracks_list.remove(idx)

func to_array() -> Array :
	return tracks_list

func from_array(from: Array) -> void :
	for track in from:
		var is_has := false
		for track_from_list in tracks_list:
			if track_from_list.id == track.id:
				is_has = true
		if not is_has:
			tracks_list.append(track)
