extends Control

var client_id : String = Global.client_id 
var channel : String = Global.channel
var bot_username : String = Global.bot_username

var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection
var eventsub : TwitchEventSubConnection
var cmd_handler : GIFTCommandHandler
var iconloader : TwitchIconDownloader

@onready var play_button = %Play
@onready var exit_button = %Exit

var mouse_in_bg = false
func _ready():
	%player.text = Global.channel
	Global.players = {}
	Global.refresh_code()

	id = Global.id
	api = Global.api
	irc = Global.irc
	eventsub = Global.eventsub
	cmd_handler = Global.cmd_handler
	iconloader = Global.iconloader

	cmd_handler.add_command("join", join_game, 1, 1)
	cmd_handler.add_command("leave", leave_game)

	cmd_handler.add_command("kick", command_kick, 1, 1)

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
	if event.is_action_pressed("reveal_code") and !cooldown and !%player.has_focus():
		cooldown = true
		if code_hidden:
			await type_code("****", Global.code)
			code_hidden = false
		else:
			await type_code(Global.code, "****", true)
			code_hidden = true
	cooldown = false
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if mouse_in_bg:
				%player.release_focus()
func update():
	var pos = 0
	for panel in %Players.get_children():
		panel.modulate = "#ffffff53"
		panel.get_child(0).text = ""
	for player in Global.players:
		%Players.get_child(pos).get_child(0).text = player
		%Players.get_child(pos).modulate = "#ffffff"
		pos += 1

func join_game(cmd_info : CommandInfo, code : PackedStringArray) -> void:
	if code[0].to_upper() == Global.code or not Global.password_protected:
		if Global.players.keys().find(cmd_info.sender_data.tags["display-name"]) == -1 and len(Global.players.keys()) < 8 and Global.blacklist.find(cmd_info.sender_data.tags["display-name"]) == -1:
				Global.players[cmd_info.sender_data.tags["display-name"]] = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/player_dict.json"))
				MusicHandler.play_sfx("res://assets/sfx/bell-98033.mp3")
	update()
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
	if len(Global.players) > 0:
		%start.play("start")
		%StartTimer.start(3)
		while %StartTimer.time_left > 1:
			$timer.text = str(ceil(%StartTimer.time_left))
			await get_tree().process_frame
		$timer.text = "1"
		await %StartTimer.timeout
		$timer.text = "0"
		SceneTransition.change_scene_close("res://scenes/trivitime/tt_questions.tscn", "#598647")

func back():
	SceneTransition.change_scene_close("res://scenes/trivitime/tt_config.tscn", "#598647")

func kick_player(plr):
	var kick_plr = plr
	if plr is String: 
		if Global.players.keys().find(plr) == -1: return
	else:
		if len(Global.players.keys()) - 1 > plr: return
		kick_plr = Global.players.keys()[plr]
	MusicHandler.play_sfx("res://assets/sfx/woosh-230554.mp3")
	Global.players.erase(kick_plr)
	update()
	
func command_kick(cmd_info : CommandInfo, player_to_kick):
	if cmd_info.sender_data.tags["mod"]:
		player_to_kick = Array(player_to_kick)[0]
		
		MusicHandler.play_sfx("res://assets/sfx/woosh-230554.mp3")
		Global.players.erase(player_to_kick)
		update()

func difficulty_changed_bot(new_diff : float):
	var difficulties = ["Easy", "Medium", "Hard", "Lore Accurate"]
	%difficulty_txt.text = difficulties[int(new_diff) - 1]

func join():
	if str(%player.text).strip_edges(true, true) != "":
		if Global.players.keys().find(%player.text) == -1 and len(Global.players.keys()) < 8:
			Global.players[%player.text] = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/player_dict.json"))
			MusicHandler.play_sfx("res://assets/sfx/bell-98033.mp3")
			update()

func _on_bg_mouse_entered() -> void:
	mouse_in_bg = true

func _on_bg_mouse_exited() -> void:
	mouse_in_bg = false
