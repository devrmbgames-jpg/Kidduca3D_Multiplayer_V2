extends Reference
#class_name GameStatePurchasedGames

var purchased_games_list := []

func push_purchased_game(product_id: int) -> void :
	if not purchased_games_list.has(str(product_id)):
		purchased_games_list.append(str(product_id))

func has_purchased_game(product_id: int) -> bool :
	return purchased_games_list.has(str(product_id))


func to_array() -> Array :
	return purchased_games_list

func from_array(from: Array) -> void :
	for game in from:
		if not purchased_games_list.has(game):
			purchased_games_list.append(game)
