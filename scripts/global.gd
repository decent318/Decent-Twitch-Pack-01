extends Node

signal Game_Over
signal twitch_setup

var players = {
	#"test_account01": {"points": 300, "supporters": ["1"], "TRIVITIME": {"streak": 0, "answer_history": [true, false, false, false, false, false]}, "icon_data": {"file": "", "color": "#ffffff"}},
	#"test_account02": {"points": 0, "supporters": ["1"], "TRIVITIME": {"streak": 0, "ans_times": []}, "icon_data": {"file": "", "color": "#ffffff"}},
	#"test_account03": {"points": 0, "supporters": ["1"], "TRIVITIME": {"streak": 0, "ans_times": []}, "icon_data": {"file": "", "color": "#ffffff"}},
	#"test_account04": {"points": 0, "supporters": ["1"], "TRIVITIME": {"streak": 0, "ans_times": []}, "icon_data": {"file": "", "color": "#ffffff"}},
	#"test_account05": {"points": 0, "supporters": ["1"], "TRIVITIME": {"streak": 0, "ans_times": []}, "icon_data": {"file": "", "color": "#ffffff"}},
	#"test_account06": {"points": 0, "supporters": ["1"], "TRIVITIME": {"streak": 0, "ans_times": []}, "icon_data": {"file": "", "color": "#ffffff"}},
	#"test_account07": {"points": 0, "supporters": ["1"], "TRIVITIME": {"streak": 0, "ans_times": []}, "icon_data": {"file": "", "color": "#ffffff"}},
	#"test_account08": {"points": 0, "supporters": ["1"], "TRIVITIME": {"streak": 0, "ans_times": []}, "icon_data": {"file": "", "color": "#ffffff"}},
	
	#"bot_01": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": []}},
	#"bot_02": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": []}},
	#"bot_03": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": []}},
	#"bot_04": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": []}},
	#"bot_05": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": []}},
	#"bot_06": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": []}},
	#"bot_07": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": []}},
	#"bot_08": {"points": 0, "supporters": [], "TRIVITIME": {"streak": 0, "ans_times": []}},
	
	#"decent_games": JSON.parse_string(FileAccess.get_file_as_string("res://scripts/player_dict.json")),
}


var channel : String = "decent_games"
var bot_username := "TriviTime"
var client_id = "2u590w96urx0e817va3xmt4sp8vjuz"

const alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var code_length = 4
var code = ""

var blacklist = ["decent_games"] # Players not allowed in the game

var leaderboard: Leaderboard

var MaxRounds = 10
var CurrentRound = 1

var saved_token : UserAccessToken

func refresh_code():
	code = ""
	for digit in code_length:
		code = code + alphabet[randi_range(0, 25)]

var id : TwitchIDConnection
var irc : TwitchIRCConnection
var api : TwitchAPIConnection
var iconloader : TwitchIconDownloader
var eventsub : TwitchEventSubConnection
var cmd_handler : GIFTCommandHandler = GIFTCommandHandler.new()

var token : UserAccessToken
var auth: ImplicitGrantFlow
func _ready():
	auth = ImplicitGrantFlow.new()
	# For the auth to work, we need to poll it regularly.
	get_tree().process_frame.connect(auth.poll) # You can also use a timer if you don't want to poll on every frame.

	# Next, we actually get our token to authenticate. We want to be able to read and write messages,
	# so we request the required scopes. See https://dev.twitch.tv/docs/authentication/scopes/#twitch-access-token-scopes
	token = await(auth.login(client_id, ["chat:read", "chat:edit"]))
	if (token == null):
		# Authentication failed. Abort.
		return
		
	await setup_twitch()
	
	twitch_setup.emit()
	
func setup_twitch():
	get_tree().process_frame.connect(auth.poll) # You can also use a timer if you don't want to poll on every frame.

	# Next, we actually get our token to authenticate. We want to be able to read and write messages,
	# so we request the required scopes. See https://dev.twitch.tv/docs/authentication/scopes/#twitch-access-token-scopes

	var token = Global.token
	if (token == null):
		return
	# Store the token in the ID connection, create all other connections.
	id = TwitchIDConnection.new(token)
	irc = TwitchIRCConnection.new(id)
	api = TwitchAPIConnection.new(id)
	iconloader = TwitchIconDownloader.new(api)
	# For everything to work, the id connection has to be polled regularly.
	get_tree().process_frame.connect(id.poll)

	# Connect to the Twitch chat.
	if(!await(irc.connect_to_irc(bot_username))):
		# Authentication failed. Abort.
		return
	# Request the capabilities. By default only twitch.tv/commands and twitch.tv/tags are used.
	# Refer to https://dev.twitch.tv/docs/irc/capabilities/ for all available capapbilities.
	irc.request_capabilities()
	# Join the channel specified in the exported 'channel' variable.
	irc.join_channel(channel)
