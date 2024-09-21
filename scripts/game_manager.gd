extends Node

signal Game_Over

var players = {
	"test_account01": {"points": 0, "supporters": ["1"], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "bot": 0, "icon_data": {"file": "", "color": "#ffffff"}},
	"test_account02": {"points": 100, "supporters": ["1", "2"], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "bot": 0, "icon_data": {"file": "", "color": "#ffffff"}},
	"test_account03": {"points": 1000, "supporters": ["1", "2", "3"], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0},"bot": 0, "icon_data": {"file": "", "color": "#ffffff"}},
	"test_account04": {"points": -400, "supporters": ["1", "2", "3", "4"], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "bot": 0, "icon_data": {"file": "", "color": "#ffffff"}},
	"test_account05": {"points": -1000, "supporters": ["1", "2", "3", "4", "5"], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 2},"bot": 0, "icon_data": {"file": "", "color": "#ffffff"}},
	"test_account06": {"points": 50, "supporters": ["1", "2", "3", "4", "5", "6"], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 2}, "bot": 0, "icon_data": {"file": "", "color": "#ffffff"}},
	"test_account07": {"points": 7550, "supporters": ["1", "2", "3", "4", "5", "6", "7"], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 2}, "bot": 0, "icon_data": {"file": "", "color": "#ffffff"}},
	"test_account08": {"points": 88, "supporters": ["1", "2", "3", "4", "5", "6", "7", "8"], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 2}, "bot": 0, "icon_data": {"file": "", "color": "#ffffff"}},
	
	#"bot_01": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 1}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 1},
	#"bot_02": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 1}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 2},
	#"bot_03": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 1}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 3},
	#"bot_04": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 1}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 4},
	#"bot_05": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 2}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 1},
	#"bot_06": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 2}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 2},
	#"bot_07": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 2}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 3},
	#"bot_08": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 2}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 4},
	
	#"team_test_01": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 0},
	#"team_test_02": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 0},
	#"team_test_03": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 0},
	#"team_test_04": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 0},
	#"team_test_05": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 0},
	#"team_test_06": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 0},
	#"team_test_07": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 0},
	#"team_test_08": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "CTE" : {"gold": 0, "job": "unemployed"}, "bot": 0},
	
	
	#"decent_games": {"points": 0, "supporters": [""], "TRIVITIME": {"streak": 0, "ans_times": [], "stocks": 3}, "CVSC": {"team": 0}, "bot": 0},
}

var alive_players = players.keys()

enum GAME_MODES {SINGULAR, MULTICHOICE, PINPOINT}
var GAME_MODE = GAME_MODES.SINGULAR

@export var channel : String
@export var username := "TriviTime"
@export var client_id = "2u590w96urx0e817va3xmt4sp8vjuz"

const alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var code_length = 4
var code = ""
var password_protected := true

var Blacklist = [] # Players not allowed in the game

var CORRECT_BENEFIT = 100
var WRONG_PENALTY = -50
 
var Quadrant = 1

var MaxRounds = 10
var CurrentRound = 1
var turn = 0:
	set(value):
		turn = value % len(players.keys())
		if turn == 0:
			if CurrentRound == MaxRounds:
				CurrentRound = -1
				Game_Over.emit()
			else:
				CurrentRound += 1

var Questions = JSON.parse_string(FileAccess.get_file_as_string("res://questions/all trivia.json"))

var saved_token : UserAccessToken

func update_token():
	var auth : ImplicitGrantFlow = ImplicitGrantFlow.new()
	# For the auth to work, we need to poll it regularly.
	get_tree().process_frame.connect(auth.poll) # You can also use a timer if you don't want to poll on every frame.
	saved_token = await(auth.login("2u590w96urx0e817va3xmt4sp8vjuz", ["chat:read", "chat:edit"]))
	if (saved_token == null):
		# Authentication failed. Abort.
		return

func refresh_code():
	code = ""
	for digit in code_length:
		code = code + alphabet[randi_range(0, 25)]

func sortPlayers(groups : int, each : int):
	var keys = alive_players
	var sortedDict = {}
	for i in groups:
		sortedDict[str(i + 1)] = []
	for key in keys:
		var quadrant = ceil((float(keys.find(key) + 1)) / float(each))
		if quadrant > groups:
			sortedDict["1"].append(key)
		else:
			sortedDict[str(quadrant)].append(key)
	return sortedDict

var token : UserAccessToken
var auth: ImplicitGrantFlow
func _ready():
	MusicHandler.start_track("res://assets/music/SWAG_JAZZ.mp3", -20.00)
	refresh_code()
	auth = ImplicitGrantFlow.new()
	# For the auth to work, we need to poll it regularly.
	get_tree().process_frame.connect(auth.poll) # You can also use a timer if you don't want to poll on every frame.

	# Next, we actually get our token to authenticate. We want to be able to read and write messages,
	# so we request the required scopes. See https://dev.twitch.tv/docs/authentication/scopes/#twitch-access-token-scopes
	token = await(auth.login(client_id, ["chat:read", "chat:edit"]))
	if (token == null):
		# Authentication failed. Abort.
		return
