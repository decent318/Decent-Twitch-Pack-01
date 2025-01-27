class_name Leaderboard
extends Resource

var hall_of_fame = {
	"test_account01": {"tt": {"high_score": 500}, "wc": {"high_score": 300}},
	"test_account02": {"tt": {"high_score": 700}},
	"test_account03": {"tt": {"high_score": 300}},
}

func return_leaderboard(leaderboard : Dictionary, stat, game = "") -> Dictionary:
	var leaderboard_players = leaderboard.keys()
	var new_leaderboard : Dictionary
	for player in leaderboard_players:
		if game != "":
			if leaderboard[player].keys().find(game) == -1:
				continue
			else:
				if leaderboard[player][game].keys().find(stat) == -1:
					continue
		else:
			if leaderboard[player].keys().find(stat) == -1:
				continue
				
		if game != "":
			new_leaderboard[player] = leaderboard[player][game][stat]
		else:
			if stat != "":
				new_leaderboard[player] = leaderboard[player][stat]
		
	var keys: Array = new_leaderboard.keys()
	keys.sort_custom(func(x: String, y: String) -> bool: return new_leaderboard[x] > new_leaderboard[y])
	
	var final_leaderboard : Dictionary
	
	for k in keys:
		final_leaderboard[k] = new_leaderboard[k]
	return final_leaderboard

func limit_leaderboard(leaderboard : Dictionary, limit):
	var pos = 0
	while len(leaderboard) > limit:
		leaderboard.erase(leaderboard.keys()[len(leaderboard) - 1 - pos])
	return leaderboard
