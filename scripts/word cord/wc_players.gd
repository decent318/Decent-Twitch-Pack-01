extends Control

# Your client id. You can share this publicly. Default is my own client_id.
# Please do not ship your project with my client_id, but feel free to test with it.
# Visit https://dev.twitch.tv/console/apps/create to create a new application.
# You can then find your client id at the bottom of the application console.
# DO NOT SHARE THE CLIENT SECRET. If you do, regenerate it.
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

func _ready():
	#GameManager.players = {}
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

	cmd_handler.add_command("join", join_game, 1, 1)
	cmd_handler.add_command("leave", leave_game)

	# For the chat example to work, we forward the messages received to the put_chat function.

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
	update()

var code_hidden = true
var cooldown = false
func _input(event):
	if event.is_action_pressed("reveal_code") and not cooldown:
		cooldown = true
		if code_hidden:
			var str:String = "xxxx"
			for i in range(GameManager.code_length):
				str = str.substr(0, len(str) - 1)
				%code.text = str
				await get_tree().create_timer(0.05).timeout
			var code = GameManager.code
			for i in range(GameManager.code_length):
				str = code.substr(0, i + 1)
				%code.text = str
				await get_tree().create_timer(0.05).timeout
			code_hidden = false
			cooldown = false
		else:
			var str:String = GameManager.code
			for i in range(GameManager.code_length):
				str = str.substr(0, len(str) - 1)
				%code.text = str
				await get_tree().create_timer(0.05).timeout
			for i in range(GameManager.code_length):
				str += "x"	
				%code.text = str
				await get_tree().create_timer(0.05).timeout
			code_hidden = true
			cooldown = false

func update():
	var pos = 0
	for panel in %Players.get_children():
		panel.modulate = "#b7ffff9b"
		panel.get_child(0).text = ""
	for player in GameManager.players:
		%Players.get_child(pos).get_child(0).text = player
		%Players.get_child(pos).modulate = "#ffffff"
		pos += 1

func join_game(cmd_info : CommandInfo, code : PackedStringArray) -> void:
	if code[0].to_upper() == GameManager.code or not GameManager.password_protected:
		if GameManager.players.keys().find(cmd_info.sender_data.tags["display-name"]) == -1 and len(GameManager.players.keys()) < 7:
				GameManager.players[cmd_info.sender_data.tags["display-name"]] = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/player_dict.json"))
				MusicHandler.play_sfx("res://assets/sfx/bell-98033.mp3")
	update()
	print("code do be working")
	
func leave_game(cmd_infor : CommandInfo) -> void:
	if GameManager.players.keys().find(cmd_infor.sender_data.tags["display-name"]) != -1:
		MusicHandler.play_sfx("res://assets/sfx/woosh-230554.mp3")
		GameManager.players.erase(cmd_infor.sender_data.tags["display-name"])
		update()

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

func play():
	if len(GameManager.players.keys()) < 7:
		SceneTransition.change_scene_close("res://scenes/word cord/wc_game.tscn", "#d43d5e")
