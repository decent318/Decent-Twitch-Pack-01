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

var locked : bool = false
func _ready():
	Global.players = {}
	Global.refresh_code()

	id = Global.id
	api = Global.api
	irc = Global.irc
	eventsub = Global.eventsub
	cmd_handler = Global.cmd_handler
	iconloader = Global.iconloader

	cmd_handler.add_command("join", join_game)
	cmd_handler.add_command("leave", leave_game)

	cmd_handler.add_command("kick", command_kick, 1, 1)

	irc.chat_message.connect(cmd_handler.handle_command)
	irc.whisper_message.connect(cmd_handler.handle_command.bind(true))
	
	prompt_tip()
	
	update(CONTEXT.ALL_PLAYERS)

var cooldown = false
func _input(event):
	if event.is_action_pressed("reveal_code"):
		cooldown = true
		if locked:
			%code.text = "!JOIN"
			locked = false
		else:
			%code.text = "LOCKED"
			locked = true
		SoundHandler.play_sfx("res://assets/sfx/click.wav")
	cooldown = false
	
enum CONTEXT {PLAYER_JOIN, PLAYER_LEFT, ALL_PLAYERS}

func update(context : CONTEXT, player : String = "all"):
	print("CONTEXT_" + str(context))
	match context:
		CONTEXT.PLAYER_JOIN: # PLAYER JOINS
			if Global.players.keys().has(Global.channel): %join.text = "LEAVE"
			print(player)
			print("PLAYER JOINED!")
			
			var player_panel : Button = %player_panel.duplicate()
			var username : Label  = player_panel.get_child(0)
			
			username.text = player
			player_panel.self_modulate = Global.player_colors[len(Global.players.keys()) - 1]
			
			player_panel.name = player
			
			player_panel.pressed.connect(kick_player.bind(player))
			
			player_panel.visible = true
			%players.add_child(player_panel)
		CONTEXT.PLAYER_LEFT: # PLAYER LEAVES
			if !Global.players.keys().has(Global.channel): %join.text = "JOIN"
			var player_panel = %players.find_child(player, false, false)
			
			player_panel.name = "TRASHED"
			
			%players.remove_child(player_panel)
			player_panel.queue_free()
			
			var pos = 0
			for plr : Button in %players.get_children():
				plr.self_modulate = Global.player_colors[pos]
				pos += 1

func join_game(cmd_info : CommandInfo) -> void:
	if locked: return
	var plr_name = cmd_info.sender_data.tags["display-name"]
	print(plr_name)
	if Global.players.keys().find(plr_name) == -1 and len(Global.players.keys()) < 8 and Global.blacklist.find(plr_name) == -1:
			Global.players[plr_name] = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/player_dict.json"))
			SoundHandler.play_sfx("res://assets/sfx/bell-98033.mp3")
			update(CONTEXT.PLAYER_JOIN, plr_name)

func leave_game(cmd_infor : CommandInfo) -> void:
	var plr_name = cmd_infor.sender_data.tags["display-name"]
	if Global.players.keys().find(plr_name) != -1:
		SoundHandler.play_sfx("res://assets/sfx/woosh-230554.mp3")
		Global.players.erase(plr_name)
		update(CONTEXT.PLAYER_LEFT, plr_name)

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
		SceneTransition.change_scene_close("res://scenes/trivitime/tt_questions.tscn", "#000000")

func back():
	SceneTransition.change_scene_close("res://scenes/trivitime/tt_config.tscn", "#000000")

func kick_player(plr):
	var kick_plr = plr
	if plr is String: 
		if Global.players.keys().find(plr) == -1: return
	else:
		if len(Global.players.keys()) - 1 > plr: return
		kick_plr = Global.players.keys()[plr]
	SoundHandler.play_sfx("res://assets/sfx/woosh-230554.mp3")
	Global.players.erase(kick_plr)
	update(CONTEXT.PLAYER_LEFT, kick_plr)
	
func command_kick(cmd_info : CommandInfo, player_to_kick):
	if cmd_info.sender_data.tags["mod"]:
		player_to_kick = Array(player_to_kick)[0]
		
		SoundHandler.play_sfx("res://assets/sfx/woosh-230554.mp3")
		Global.players.erase(player_to_kick)
		update(CONTEXT.PLAYER_LEFT, player_to_kick)

func difficulty_changed_bot(new_diff : float):
	var difficulties = ["Easy", "Medium", "Hard", "Lore Accurate"]
	%difficulty_txt.text = difficulties[int(new_diff) - 1]

func join():
	if str(Global.channel).strip_edges(true, true) != "":
		if Global.players.keys().find(Global.channel) == -1:
			if len(Global.players.keys()) < 8:
				Global.players[Global.channel] = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/player_dict.json"))
				SoundHandler.play_sfx("res://assets/sfx/bell-98033.mp3")
				%join.text = "LEAVE"
				update(CONTEXT.PLAYER_JOIN, Global.channel)
		else:
			Global.players.erase(Global.channel)
			SoundHandler.play_sfx("res://assets/sfx/woosh-230554.mp3")
			%join.text = "JOIN"
			update(CONTEXT.PLAYER_LEFT, Global.channel)
	
func _on_debug_text_submitted(new_text: String) -> void:
	if str(new_text).strip_edges(true, true) != "":
		if Global.players.keys().find(new_text) == -1 and len(Global.players.keys()) < 8:
			Global.players[new_text] = JSON.parse_string(FileAccess.get_file_as_string("res://scripts/player_dict.json"))
			SoundHandler.play_sfx("res://assets/sfx/bell-98033.mp3")
			update(CONTEXT.PLAYER_JOIN, new_text)

var tips = [
	"The first recorded instance of 'TriviTime' was made on March 31, 2024, my birthday!",
	"Even if you're not in the game, you can vote on an answer with !vote.",
	"Confident in a contestant? Support them with !support [name]",
	"If you do good enough, you can make your way on the leaderboard!"
]

var unused_tips = tips.duplicate()

func prompt_tip():
	SoundHandler.play_sfx("res://assets/sfx/type.wav")
	var tip = unused_tips.pick_random()
	%tip.text = tip
	unused_tips.erase(tip)
	if unused_tips.is_empty(): unused_tips = tips
	get_tree().create_timer(10).timeout.connect(prompt_tip)
	
