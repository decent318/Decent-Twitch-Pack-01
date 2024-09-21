extends Control

@export_dir var IconFolder = "res://assets/sprites/trivitime/plr_icons/better_icons/"
@export var Colors := {"red": Color("ff1c4b"), "orange": Color("fa7300"), "yellow": Color("e8bb00"), "green": Color("8fc100"), "blue": Color("24baff"), "purple": Color("a168ff"), "pink": Color("ef78ff"), "white": Color("ffffff"), "black": Color("000000")}

func keepFilesOfType(files : Array, keep_extension : String) -> Array:
	var new_files = []
	for file : String in files:
		if file.ends_with(keep_extension):
			new_files.append(file)
	return new_files

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

func _ready():
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

	cmd_handler.add_command("icon", icon, 2, 2)
	
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
	
	var better_icons = makeNumberedArray(17, 1, "Vector-", ".svg")
	print(better_icons)
	better_icons = keepFilesOfType(better_icons, ".svg")
	var pos = 1
	for cur_icon in better_icons:
		var panel = %templateIcon.duplicate()
		panel.get_child(0).texture = load(IconFolder + cur_icon)
		panel.get_child(1).text = str(pos)
		panel.visible = true
		$IconContainer.add_child(panel)
		pos += 1

	pos = 1
	for color in Colors:
		var panel = %templateColor.duplicate()
		panel.get_child(0).modulate = Colors[color]
		panel.get_child(1).text = str(color).to_upper()
		if pos <= 7:
			panel.visible = true
		$ColorContainer.add_child(panel)
		pos += 1
		
	update()

func makeNumberedArray(length, start = 0, prefix : String = "", suffix : String = ""):
	var new_array : Array = []
	for i in length:
		new_array.append(prefix + str(i + start) + suffix)
	print(new_array)
	return new_array
	
func update():
	var pos = 0
	for plr in GameManager.players:
		if pos == 4:
			print("hello peak")
			pos += 1
		if $PlayerContainer.get_child(pos) is TextureRect:
			if GameManager.players[plr].icon_data.file != "":
				$PlayerContainer.get_child(pos).texture = load(GameManager.players[plr].icon_data.file)
			else:
				$PlayerContainer.get_child(pos).texture = load("res://assets/sprites/trivitime-icon.svg")
			if GameManager.players[plr].icon_data.color == "RAINBOW":
				var shader_material = ShaderMaterial.new()
				shader_material.shader = load("res://shaders/rainbow.gdshader")
				$PlayerContainer.get_child(pos).material = shader_material
			else:
				$PlayerContainer.get_child(pos).self_modulate = GameManager.players[plr].icon_data.color
			$PlayerContainer.get_child(pos).get_child(0).text = plr
		pos += 1

func icon(cmd_info : CommandInfo, icon_data : PackedStringArray):
	var sender = cmd_info.sender_data.tags["display-name"]
	if GameManager.players.keys().find(sender) != -1:
		match icon_data[0].to_lower():
			"frank", "frankocean":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/frank.jpg"
			"kdot", "kendrick":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/kdot.jpg"
			"drizzy", "drake":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/drizzy.jpeg"
			"donald", "donaldtrump", "trump":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/donald.jpg"
			"eminem", "shady", "marshall":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/eminem.jpg"
			"kanye", "kanyewest":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/kanye.jpg"
			"diddy", "pdiddy":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/diddy.jpg"
			"duke", "dukedennis":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/duke dennis.jpg"
			"hawk", "hawktuahgirl":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/hawk.png"
			"skibidi", "skibiditoilet":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/skibidi.jpg"
			"tyler", "tylerthecreator":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/tyler.jpg"
			"mattitap", "theflormatt":
				if sender == "TheFlorMatt": GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/flormatt.png"
				else: return
			"yusuf":
				GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/yusuf.jpg"
			"decent", "decent_games":
				if sender == "decent_games": GameManager.players[sender].icon_data.file = "res://assets/sprites/trivitime/decent.jpg"
				else: return
			_:
				GameManager.players[sender].icon_data.file = $IconContainer.get_child(clamp(int(icon_data[0]) - 1, 0, $IconContainer.get_child_count())).get_child(0).texture.resource_path
		if len(icon_data) > 1:
			if Colors.keys().find(icon_data[1].to_lower()) != -1:
				GameManager.players[sender].icon_data.color = Colors.keys()[Colors.keys().find(icon_data[1].to_lower())]
			else:
				if icon_data[1].to_lower() == "rainbow":
					print("RAINBOW COLOR ACTIVATED")
					GameManager.players[sender].icon_data.color = "RAINBOW"
				else:
					GameManager.players[sender].icon_data.color = icon_data[1]
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
