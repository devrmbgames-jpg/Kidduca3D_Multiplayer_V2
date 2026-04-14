extends Reference
#class_name GameStateReward

var profile := {
	"name" : "",
	"age" : "",
	"ava" : "CAT",
	"age_button" : ""
}



func push_name(name_profile: String) -> void :
	profile.name = name_profile

func push_age(age_profile: String) -> void :
	profile.age = age_profile

func push_ava(ava_profile: String) -> void :
	profile.ava = ava_profile

func push_age_button(age_button: String) -> void :
	profile.age_button = age_button

func get_name() -> String :
	return profile.name

func get_age() -> String :
	return profile.age

func get_age_button() -> String :
	return profile.age_button

func get_ava() -> String :
	return profile.ava

func reset_profile() -> void :
	profile.name = ""
	profile.age = ""
	profile.ava = "CAT"
	profile.age_button = ""


func to_dictionary() -> Dictionary :
	return profile

func from_dictionary(dict: Dictionary) :
	for key in dict :
		profile[key] = dict[key]
