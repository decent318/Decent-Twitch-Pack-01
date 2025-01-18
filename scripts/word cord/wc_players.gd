extends Control

var client_id : String = Global.client_id 
var channel : String = Global.channel
var bot_username : String = Global.username

var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection
var eventsub : TwitchEventSubConnection

var cmd_handler : GIFTCommandHandler = GIFTCommandHandler.new()

var iconloader : TwitchIconDownloader

func _ready():
	Global.players = {}
	var twitch_setup = await Global.setup_twitch(id, irc, api, iconloader)
	id = twitch_setup[0]
	irc = twitch_setup[1]
	api = twitch_setup[2]
	iconloader = twitch_setup[3]

	cmd_handler.add_command("join", join_game, 1, 1)
	cmd_handler.add_command("leave", leave_game)

	irc.chat_message.connect(cmd_handler.handle_command)
	irc.whisper_message.connect(cmd_handler.handle_command.bind(true))

	update()

func type_code(from : String, text : String, reverse := false):
	%code.text = from
	var string : String= from
	for i in text.length():
		if !reverse:
			string[i] = text[i]
		else:
			string[text.length() - i - 1] = text[text.length() - i - 1]
		print(string)
		%code.text = string
		await get_tree().create_timer(0.05).timeout

var code_hidden = true
var cooldown = false
func _input(event):
	if event.is_action_pressed("reveal_code") and !cooldown:
		cooldown = true
		if code_hidden:
			await type_code("????", Global.code)
			code_hidden = false
		else:
			await type_code(Global.code, "????", true)
			code_hidden = true
	cooldown = false

func update():
	var pos = 0
	for panel in %Players.get_children():
		panel.modulate = "#b7ffff9b"
		panel.get_child(0).text = ""
	for player : String in Global.players:
		%Players.get_child(pos).get_child(0).text = player
		%Players.get_child(pos).get_child(1).text = player.substr(0, 1).to_upper()
		%Players.get_child(pos).modulate = "#ffffff"
		pos += 1

func join_game(cmd_info : CommandInfo, code : PackedStringArray) -> void:
	if code[0].to_upper() == Global.code or not Global.password_protected:
		if Global.players.keys().find(cmd_info.sender_data.tags["display-name"]) == -1 and len(Global.players.keys()) < 7:
				Global.players[cmd_info.sender_data.tags["display-name"]] = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/player_dict.json"))
				MusicHandler.play_sfx("res://assets/sfx/bell-98033.mp3")
	update()
	print("code do be working")
	
func leave_game(cmd_infor : CommandInfo) -> void:
	if Global.players.keys().find(cmd_infor.sender_data.tags["display-name"]) != -1:
		MusicHandler.play_sfx("res://assets/sfx/woosh-230554.mp3")
		Global.players.erase(cmd_infor.sender_data.tags["display-name"])
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
	if len(Global.players.keys()) < 7:
		SceneTransition.change_scene_close("res://scenes/word cord/wc_game.tscn", "#d43d5e")
