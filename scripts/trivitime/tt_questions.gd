extends Control

@onready var round = %Round
@onready var players_container = %Players

var answers = []
var ansLetter
var letters = ["A", "B", "C", "D"]

var sortedPlayers = GameManager.sortPlayers(4, 2)

var game_active = true

var freshQuestions 

var time_elapsed
var is_stopped := false

func update():
	%stats.position.y = 780
	%stats.size = Vector2(1760, 300)
	%Players.size.y = 200
	%Players.position.y = 100
	if game_active:
		round.text = "Round " + str(GameManager.CurrentRound) + " of " + str(GameManager.MaxRounds)
	else:
		round.text = ""
	displayPlayers(GameManager.players, true)
			
func displayPlayers(from, specifics : bool):
	var pos = 0
	var plr
	for panel in players_container.get_children():
		panel.visible = false
		panel.get_child(2).visible = false
		panel.get_child(4).visible = false
	for player in from:
		players_container.get_child(pos).texture = load(GameManager.players[player].icon_data.file)
		if GameManager.players[player].icon_data.color == "RAINBOW":
			var shader_material = ShaderMaterial.new()
			shader_material.shader = load("res://shaders/rainbow.gdshader")
			players_container.get_child(pos).material = shader_material
		else:
			players_container.get_child(pos).self_modulate = Color(GameManager.players[player].icon_data.color)
		if GameManager.players.keys()[GameManager.turn] == player:
			players_container.get_child(pos).get_child(4).visible = true
		plr = GameManager.players[player]
		if GameManager.players[player].bot != 0:
			var bot_diff = GameManager.players[player].bot
			match bot_diff: # BOT COLORS
				1: # EASY
					players_container.get_child(pos).get_child(0).modulate = "20f747"
				2: # MEDIUM
					players_container.get_child(pos).get_child(0).modulate = "e7f720"
				3: # HARD
					players_container.get_child(pos).get_child(0).modulate = "f75720"
				4: # LORE ACCURATE
					players_container.get_child(pos).get_child(0).modulate = "b620f7"
		else:
			players_container.get_child(pos).get_child(0).modulate = "ffffff"
		players_container.get_child(pos).get_child(0).text = player
		if specifics:
			players_container.get_child(pos).get_child(1).text = str(plr.points)
			var status = ""
			# LOWEST PRIORITY
			if plr.TRIVITIME.streak > 4: 
				players_container.get_child(pos).get_child(3).texture = load("res://assets/sprites/fire.svg")
				status = "streak"
			# HIGHEST PRIORITY
			if plr.points < 0:
				players_container.get_child(pos).get_child(3).texture = load("res://assets/sprites/down.svg")
				status = "neg."
			if status == "":
				players_container.get_child(pos).get_child(3).texture = null

			if len(plr.supporters) > 0:
				players_container.get_child(pos).get_child(2).get_child(0).text = str(len(plr.supporters))
				players_container.get_child(pos).get_child(2).visible = true
		players_container.get_child(pos).visible = true
		pos += 1

func newQuestion():
		var old_t = GameManager.turn
		var old_r = GameManager.CurrentRound
		%TimerClock.start(SecondsToAnswer)
		%TimerClock.timeout.connect(func ():
			if old_r == GameManager.CurrentRound and old_t == GameManager.turn:
				skip()
		)
		time_elapsed = 0.0
		is_stopped = false
		var questionPlace = randi_range(0, len(freshQuestions.questions.keys()) - 1)
		var question = freshQuestions.questions.keys()[questionPlace]
		answers = freshQuestions.questions[question]
		freshQuestions.erase(question)
		%question.text = GameManager.players.keys()[GameManager.turn] + ", " +  question
		create_tween().tween_property($Cam, "zoom", Vector2(1, 1), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		create_tween().tween_property($Cam, "position", Vector2(960, 540), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		match GameManager.GAME_MODE:
			GameManager.GAME_MODES.SINGULAR:
				for que : Button in %Questions.get_children():
					que.disabled = false
					que.modulate = "ffffff"
				var used = []
				for ans in answers:
					var spot = randi_range(0, len(answers) - 1)
					while used.find(spot) != -1:
						spot = randi_range(0, len(answers) - 1)
					%Questions.get_child(spot).text = ans
					used.append(spot)
					if ans == answers[0]:
						ansLetter = letters[spot]
				var bot_diff = GameManager.players[GameManager.players.keys()[GameManager.turn]].bot
				if bot_diff != 0 and game_active:
					var old_round = GameManager.CurrentRound
					var old_turn = GameManager.turn
					await get_tree().create_timer(randf_range(1.00, 3.50)).timeout
					if old_round == GameManager.CurrentRound and old_turn == GameManager.turn:
						if bot_diff == 1: # EASY 15%
							if randi_range(1, 20) <= 3:
								answer(null, ansLetter)
							else:
								answer(null, letters[randi_range(0, 3)])
						if bot_diff == 2: # NORMAL 35%
							if randi_range(1, 20) <= 7:
								answer(null, ansLetter)
							else:
								answer(null, letters[randi_range(0, 3)])
						if bot_diff == 3: # HARD 50%
							if randi_range(1, 20) <= 10:
								answer(null, ansLetter)
							else:
								answer(null, letters[randi_range(0, 3)])
						if bot_diff == 4: # LORE ACCURATE 75%
							if randi_range(1, 20) <= 15:
								answer(null, ansLetter)
							else:
								answer(null, letters[randi_range(0, 3)])

@export var client_id : String = "2u590w96urx0e817va3xmt4sp8vjuz"
# The name of the channel we want to connect to.
var channel : String = GameManager.channel
# The username of the bot account.
var username : String = "TriviTime"

var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection
var eventsub : TwitchEventSubConnection

var cmd_handler : GIFTCommandHandler = GIFTCommandHandler.new()

var iconloader : TwitchIconDownloader

@export var SecondsToAnswer := 30

func _ready() -> void:
	freshQuestions = GameManager.Questions
	game_active = true
	MusicHandler.start_track("res://assets/music/Guesstimation.wav")
	newQuestion()
	update()
	
	# DISPLAY SETTINGS
	match GameManager.GAME_MODE:
		GameManager.GAME_MODES.SINGULAR:
			%Questions.visible = true
			%Pinpoint.visible = false
		GameManager.GAME_MODES.MULTICHOICE:
			pass
		GameManager.GAME_MODES.PINPOINT:
			%Questions.visible = false
			%Pinpoint.visible = true
	
	
	# We will login using the Implicit Grant Flow, which only requires a client_id.
	# Alternatively, you can use the Authorization Code Grant Flow or the Client Credentials Grant Flow.
	# Note that the Client Credentials Grant Flow will only return an AppAccessToken, which can not be used
	# for the majority of the Twitch API or to join a chat room.
	# For the auth to work, we need to poll it regularly.
	get_tree().process_frame.connect(GameManager.auth.poll) # You can also use a timer if you don't want to poll on every frame.

	# Next, we actually get our token to authenticate. We want to be able to read and write messages,
	# so we request the required scopes. See https://dev.twitch.tv/docs/authentication/scopes/#twitch-access-token-scopes
	var token = GameManager.token
	if (token == null):
		# Authentication failed. Abort.
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

	cmd_handler.add_command("answer", answer, 12, 1)
	cmd_handler.add_alias("answer", "a")
	# For the chat example to work, we forward the messages received to the put_chat function.

	GameManager.Game_Over.connect(game_over)

	irc.chat_message.connect(tts_turn)

	# We also have to forward the messages to the command handler to handle them.
	irc.chat_message.connect(cmd_handler.handle_command)
	# If you also want to accept whispers, connect the signal and bind true as the last arg.
	irc.whisper_message.connect(cmd_handler.handle_command.bind(true))

	# When we press enter on the chat bar or press the send button, we want to execute the send_message
	# function.

	# This part of the example only works if GIFT is logged in to your broadcaster account.
	# If you are, you can uncomment this to also try receiving follow events.
	# Don't forget to also add the 'moderator:read:followers' scope to your token.
#	eventsub = TwitchEventSubConnection.new(api)
#	await(eventsub.connect_to_eventsub())
#	eventsub.event.connect(on_event)
#	var user_ids : Dictionary = await(api.get_users_by_name([username]))
#	if (user_ids.has("data") && user_ids["data"].size() > 0):
#		var user_id : String = user_ids["data"][0]["id"]
#		eventsub.subscribe_event("channel.follow", "2", {"broadcaster_user_id": user_id, "moderator_user_id": user_id})

func _process(delta):
	%timer.text = str(ceil(%TimerClock.time_left))
	%TimerClock.paused = is_stopped
	if !is_stopped:
		time_elapsed += delta

func suspense(ans = "A"):
	match GameManager.GAME_MODE:
		GameManager.GAME_MODES.SINGULAR:
			for que : Button in %Questions.get_children():
				que.disabled = true
				if !que.name == "Button" + ans.to_upper():
						que.modulate = "ffffff41"
		GameManager.GAME_MODES.MULTICHOICE:
			pass
		GameManager.GAME_MODES.PINPOINT:
			create_tween().tween_property($Cam, "zoom", Vector2(1.6, 1.6), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			create_tween().tween_property($Cam, "position", Vector2(960, 500), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await MusicHandler.play_sfx("res://assets/sfx/heartbeat_loop.mp3", 2)

func typewrite(text : String, length := 1.00):
	var time_per_char = float(length) / float(len(text))
	var cur_string = ""
	
	print(Array(text.split()))
	for char in Array(text.split()):
		print(char)
		cur_string += char
		%Pinpoint.text = cur_string
		await get_tree().create_timer(time_per_char).timeout

func answer(cmd_infor : CommandInfo, answer) -> void:
	# LOCAL SETUP
	var cmd_info = null
	var ans = answer
	var sender
	if answer is PackedStringArray: # answer will only be a PackedStringArray when sent from Twitch
		if GameManager.GAME_MODE == GameManager.GAME_MODES.SINGULAR:
			ans = Array(answer)[0] # Set ans to a more readable format that both local and Twitch share
		if GameManager.GAME_MODE == GameManager.GAME_MODES.PINPOINT:
			ans = Array(answer)[0] # Set ans to a more readable format that both local and Twitch share
	if cmd_infor is CommandInfo: # cmd_info will only be CommandInfo when sent from Twitch
		cmd_info = cmd_infor
		sender = cmd_info.sender_data.tags["display-name"]
	print(sender)
	
	if game_active and not is_stopped:
		var from_sender = GameManager.players.keys()[GameManager.turn] == sender 
		if !from_sender and !cmd_info == null:
			return
		var correct = ans.to_upper() == ansLetter
		if GameManager.GAME_MODE == GameManager.GAME_MODES.MULTICHOICE:
			pass
		if GameManager.GAME_MODE == GameManager.GAME_MODES.PINPOINT:
			var cap_answers : Array[String]
			for cap_answer in answers:
				cap_answers.append(cap_answer.to_upper())
			correct = cap_answers.find(ans.to_upper()) != -1
			
		if correct:
			match(GameManager.GAME_MODE):
				GameManager.GAME_MODES.SINGULAR:
					if cmd_info == null or from_sender:
						is_stopped = true # THIS STOPS THE ANSWER TIME
						GameManager.players[GameManager.players.keys()[GameManager.turn]].TRIVITIME.ans_times.append(time_elapsed)
						await suspense(ans[0])
						GameManager.players[GameManager.players.keys()[GameManager.turn]].points += 100
						GameManager.players[GameManager.players.keys()[GameManager.turn]].TRIVITIME.streak += 1
						%Correct.play()
				
				GameManager.GAME_MODES.PINPOINT:
					if cmd_info == null or from_sender:
						is_stopped = true # THIS STOPS THE ANSWER TIME
						GameManager.players[GameManager.players.keys()[GameManager.turn]].TRIVITIME.ans_times.append(time_elapsed)
						typewrite(ans, 0.3)
						DisplayServer.tts_speak(ans, "", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Voices"))) * 100)
						await suspense()
						GameManager.players[GameManager.players.keys()[GameManager.turn]].points += 100
						GameManager.players[GameManager.players.keys()[GameManager.turn]].TRIVITIME.streak += 0
						%Correct.play()
		else:
			match(GameManager.GAME_MODE):
				GameManager.GAME_MODES.SINGULAR:
					if cmd_info == null or from_sender:
						is_stopped = true
						GameManager.players[GameManager.players.keys()[GameManager.turn]].TRIVITIME.ans_times.append(time_elapsed)
						await suspense(ans[0])
						GameManager.players[GameManager.players.keys()[GameManager.turn]].TRIVITIME.streak = 0
						GameManager.players[GameManager.players.keys()[GameManager.turn]].points -= 50
						%Incorrect.play()
				GameManager.GAME_MODES.PINPOINT:
					if cmd_info == null or from_sender:
						is_stopped = true # THIS STOPS THE ANSWER TIME
						GameManager.players[GameManager.players.keys()[GameManager.turn]].TRIVITIME.ans_times.append(time_elapsed)
						typewrite(ans, 0.3)
						DisplayServer.tts_speak(ans, "", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Voices"))) * 100)
						await suspense()
						GameManager.players[GameManager.players.keys()[GameManager.turn]].points -= 50
						GameManager.players[GameManager.players.keys()[GameManager.turn]].TRIVITIME.streak = 0
						%Incorrect.play()
		GameManager.turn += 1
		newQuestion()
		update()

func game_over():
	game_active = false
	GameManager.refresh_code()
	GameManager.CurrentRound = 1
	SceneTransition.change_scene_close("res://scenes/trivitime/tt_results.tscn", "#598647")

func on_event(type : String, data : Dictionary) -> void:
	match(type):
		"channel.follow":
			print("%s followed your channel!" % data["user_name"])

func send_message(mes) -> void:
	irc.chat(mes)
	%send_message.text = ""

class EmoteLocation extends RefCounted:
	var id : String
	var start : int
	var end : int

	func _init(emote_id, start_idx, end_idx):
		self.id = emote_id
		self.start = start_idx
		self.end = end_idx

	static func smaller(a : EmoteLocation, b : EmoteLocation):
		return a.start < b.start


func skip():
	GameManager.turn += 1
	newQuestion()
	update()

func local_a():
	answer(null, "a")
func local_b():
	answer(null, "b")
func local_c():
	answer(null, "c")
func local_d():
	answer(null, "d")

func tts_turn(senderdata : SenderData, msg : String):
	var sender = senderdata.tags["display-name"]
	if GameManager.players.keys()[GameManager.turn] == sender and !msg.begins_with("!"):
		DisplayServer.tts_speak(msg, "", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Voices"))) * 100)

func togglePause():
	is_stopped = !is_stopped
	if is_stopped:
		%Pause.texture_normal = load("res://assets/sprites/play.svg")
	else:
		%Pause.texture_normal = load("res://assets/sprites/pause.svg")
