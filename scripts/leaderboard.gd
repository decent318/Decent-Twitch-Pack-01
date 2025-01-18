class_name Leaderboard
extends Resource

@export var players = [
	{"decent":
		{
		"tt": {"score": 200},
		"wc": {"score": 71}
		}
	},
	{"velk":
		{
		"tt": {"score": 120},
		}
	},
	{"kingblob":
		{
		"wc": {"score": 70},
		}
	},
]

# get list of all values and corresponding keys

enum TYPE {CURRENT, LEADERBOARD}

func return_leaderboard(type = 0, stat = "", game = "", preset_leaderboared : Dictionary = {}) -> Dictionary:
	var leaderboard : Dictionary = preset_leaderboared
	var leaderboard_players
	if type == 0:
		for plr in Global.players:
			leaderboard[plr] = Global.players[plr]["points"]
	if type == 1: leaderboard_players = players
	
	if type == 1:
		var pos = 0
		for player in leaderboard_players:
			var player_name = player.keys()[0]
			if leaderboard_players[pos][player_name].keys().find(game) != -1:
				if game != "":
					leaderboard[player_name] = leaderboard_players[pos][player_name][game][stat]
				else:
					if stat != "":
						leaderboard[player_name] = leaderboard_players[pos][player_name][stat]
					else:
						leaderboard[player_name] = leaderboard_players[pos][player_name]["points"]
			pos += 1
		
	print(leaderboard)
	var keys: Array = leaderboard.keys()
	keys.sort_custom(func(x: String, y: String) -> bool: return leaderboard[x] > leaderboard[y])
	
	var final_leaderboard : Dictionary
	
	for k in keys:
		final_leaderboard[k] = leaderboard[k]
	return final_leaderboard

func limit_leaderboard(leaderboard : Dictionary, limit):
	var pos = 0
	while len(leaderboard) > limit:
		leaderboard.erase(leaderboard.keys()[len(leaderboard) - 1 - pos])
	return leaderboard
