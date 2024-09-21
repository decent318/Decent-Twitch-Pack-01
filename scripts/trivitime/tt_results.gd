extends Control

@export var client_id : String = "2u590w96urx0e817va3xmt4sp8vjuz"
# The name of the channel we want to connect to.
@export var channel : String = GameManager.channel
# The username of the bot account.
@export var username : String

var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection
var eventsub : TwitchEventSubConnection

var cmd_handler : GIFTCommandHandler = GIFTCommandHandler.new()

var iconloader : TwitchIconDownloader

var playersScore
var sortedPlayers

func _ready():
	get_tree().process_frame.connect(GameManager.auth.poll) # You can also use a timer if you don't want to poll on every frame.

	# Next, we actually get our token to authenticate. We want to be able to read and write messages,
	# so we request the required scopes. See https://dev.twitch.tv/docs/authentication/scopes/#twitch-access-token-scopes

	var token = GameManager.token
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
	if(!await(irc.connect_to_irc(username))):
		# Authentication failed. Abort.
		return
	# Request the capabilities. By default only twitch.tv/commands and twitch.tv/tags are used.
	# Refer to https://dev.twitch.tv/docs/irc/capabilities/ for all available capapbilities.
	irc.request_capabilities()
	# Join the channel specified in the exported 'channel' variable.
	irc.join_channel(channel)
	
	irc.chat_message.connect(tts_podium)
	
	sortPlayersScore()
	for i in 3:
		$leaderboard.get_child(i).visible = true
		if i > len(GameManager.players.keys()) - 1:
			$leaderboard.get_child(i).visible = false
	for i in min(len(GameManager.players.keys()), 3):
		$leaderboard.get_child(i).get_child(0).texture = load(GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].icon_data.file)
		if GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].icon_data.color == "RAINBOW":
			var shader_material = ShaderMaterial.new()
			shader_material.shader = load("res://shaders/rainbow.gdshader")
			$leaderboard.get_child(i).get_child(0).material = shader_material
		else:
			$leaderboard.get_child(i).get_child(0).self_modulate = Color(GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].icon_data.color)
		$leaderboard.get_child(i).get_child(0).get_child(0).text = sortedPlayers[len(GameManager.players.keys()) - 1 - i]
		$leaderboard.get_child(i).get_child(0).get_child(1).text = str(GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].points)
		if GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].bot != 0:
			var bot_diff = GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].bot
			match bot_diff:
				1: # EASY
					$leaderboard.get_child(i).get_child(0).get_child(0).modulate = "20f747"
				2: # MEDIUM
					$leaderboard.get_child(i).get_child(0).get_child(0).modulate = "e7f720"
				3: # HARD
					$leaderboard.get_child(i).get_child(0).get_child(0).modulate = "f75720"
				4: # LORE ACCURATE
					$leaderboard.get_child(i).get_child(0).get_child(0).modulate = "b620f7"
		else:
			$leaderboard.get_child(i).get_child(0).get_child(0).modulate = "ffffff"
	for i in len(GameManager.players):
		$full_leaderboard.get_child(i).visible = true
		$full_leaderboard.get_child(i).get_child(0).texture = load(GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].icon_data.file)
		if GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].icon_data.color == "RAINBOW":
			var shader_material = ShaderMaterial.new()
			shader_material.shader = load("res://shaders/rainbow.gdshader")
			$full_leaderboard.get_child(i).get_child(0).material = shader_material
		else:
			$full_leaderboard.get_child(i).get_child(0).self_modulate = Color(GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].icon_data.color)
		$full_leaderboard.get_child(i).get_child(1).text = sortedPlayers[len(GameManager.players.keys()) - 1 - i]
		if GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].bot != 0:
			var bot_diff = GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].bot
			match bot_diff:
				1: # EASY
					$full_leaderboard.get_child(i).get_child(1).modulate = "20f747"
				2: # MEDIUM
					$full_leaderboard.get_child(i).get_child(1).modulate = "e7f720"
				3: # HARD
					$full_leaderboard.get_child(i).get_child(1).modulate = "f75720"
				4: # LORE ACCURATE
					$full_leaderboard.get_child(i).get_child(1).modulate = "b620f7"
		else:
			$full_leaderboard.get_child(i).get_child(1).modulate = "ffffff"
		$full_leaderboard.get_child(i).get_child(2).text = str(GameManager.players[sortedPlayers[len(GameManager.players.keys()) - 1 - i]].points)
	
func sortPlayersScore():
	playersScore = []
	for plr in GameManager.players:
		playersScore.append(GameManager.players[plr].points)
	playersScore.sort()
	print(playersScore)
	sortedPlayers = []
	for score in playersScore:
		for plr in GameManager.players:
			if GameManager.players[plr].points == score:
				sortedPlayers.append(plr)
	print(sortedPlayers)


func new_players():
	GameManager.players = {}
	SceneTransition.change_scene_close("res://scenes/trivitime/tt_players.tscn", "#598647")

func same_players():
	for plr in GameManager.players:
		GameManager.players[plr].points = 0
		GameManager.players[plr].supporters = []
		GameManager.players[plr].streak = 0
		GameManager.players[plr].ans_times = []
	SceneTransition.change_scene_close("res://scenes/trivitime/tt_questions.tscn", "#598647")

var allowed_voices = false

func tts_podium(senderdata : SenderData, msg : String):
	var sender = senderdata.tags["display-name"]
	print(sortedPlayers.find(sender))
	if (sortedPlayers.find(sender) <= 2 and sortedPlayers.find(sender) != -1) or allowed_voices:
		if !msg.begins_with("!"):
			DisplayServer.tts_speak(msg, "", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Voices"))) * 100)

