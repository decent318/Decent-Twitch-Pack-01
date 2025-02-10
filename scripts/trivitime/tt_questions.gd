extends Control

@onready var question_num = %question_num

var answers = []
var ansLetter
var letters = ["A", "B", "C", "D"]

var game_active = true

var freshQuestions 

var time_elapsed
var is_stopped := false

var client_id : String = Global.client_id 
var channel : String = Global.channel
var bot_username : String = Global.bot_username

var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection
var eventsub : TwitchEventSubConnection
var cmd_handler : GIFTCommandHandler
var iconloader : TwitchIconDownloader

var players = Global.players

var question

var total_votes = 0
var votes = [0, 0, 0, 0]
var voters = {}
func _ready() -> void:
	freshQuestions = TriviTime.Questions
	game_active = true
	SoundHandler.start_track("res://assets/music/Guesstimation.wav")
	
	id = Global.id
	api = Global.api
	irc = Global.irc
	eventsub = Global.eventsub
	cmd_handler = Global.cmd_handler
	iconloader = Global.iconloader
	
	cmd_handler.add_command("answer", answer_question, 1, 1)
	cmd_handler.add_alias("answer", "a")
	if TriviTime.AUDIENCE_VOTING == true:
		cmd_handler.add_command("vote", vote, 1, 1)
	
	irc.chat_message.connect(think)
	
	irc.chat_message.connect(cmd_handler.handle_command)
	irc.whisper_message.connect(cmd_handler.handle_command.bind(true))
	
	
	displayPlayers()
	newQuestion()
	
	for ans : Button in %Answers.get_children():
		ans.pressed.connect(
			func():
				answer_question(null, [ans.name.substr(6,1)])
		)

var SECONDS_PER_ANSWER := TriviTime.SECONDS_PER_ANSWER # THE AMOUNT OF SECONDS A PLAYER HAS TO ANSWER A QUESTION
var CURRENT_QUESTION := 0 # THE CURRENT QUESTION
var TOPIC := "HISTORY" # THE CURRENT TOPIC

var TURN = 0

func displayPlayers():
	var plrnames = players.keys()

	for player in plrnames:
		var playerStats = players[player]
		
		var tempPlayer = %templatePlayer.duplicate()
		tempPlayer.name = player
		tempPlayer.get_child(0).text = player
		tempPlayer.get_child(1).text = str(playerStats.points)
		
		tempPlayer.get_child(2).visible = false
		if player == players.keys()[TURN]:
			tempPlayer.get_child(2).visible = true
			
		%players.add_child(tempPlayer)
		tempPlayer.visible = true
	
func update():
		for player in %players.get_children():
			var playerStats = players[player.name]
			
			player.get_child(1).text = str(playerStats.points)
			player.get_child(2).visible = false
			if player.name == players.keys()[TURN]:
				player.get_child(2).visible = true

var topic_colors = {
	"HISTORY": "3163f7",
	"TECHNOLOGY": "262626",
	"LITERATURE": "ffff00",
	"ART": "f73131",
	"SCIENCE": "31f787"
}

var question_person_prefixes = [
	"THIS ONE'S FOR ",
	"SO, ",
	"OFF TO YOU, ",
	"TRY THIS ONE, "
]

func newQuestion():
	CURRENT_QUESTION += 1
	TOPIC = TriviTime.Questions.keys().pick_random()
	votes = [0, 0, 0, 0]
	total_votes = 0
	%message.text = "THINKING.."
	update_votes()
	
	for button : Button in %Answers.get_children():
		button.modulate = Color("ffffff")
	
	var topic_color = topic_colors[TOPIC.to_upper()]
	question_num.text = "QUESTION #" + str(CURRENT_QUESTION) + " - [b][color=" + topic_color + "]" + TOPIC.to_upper()
	
	question = freshQuestions[TOPIC.to_lower()].keys().pick_random()
	var correct_answer = freshQuestions[TOPIC.to_lower()][question][0]
	answers = shuffleList(freshQuestions[TOPIC.to_lower()][question])
	
	print(question)
	print(answers)
	#var string = question
	for i in len(answers):
		#string += "  " + letters[i].to_lower() + "). " + answers[i]
		%Answers.get_child(i).text = answers[i]
		if answers[i] == correct_answer:
			ansLetter = letters[i]
	# irc.chat(string)
	var plr_color = Global.player_colors.pick_random()
	plr_color = Color(plr_color).to_html(false)
	%question_person.text = "[i]" + question_person_prefixes.pick_random() + "[/i][color=" + plr_color + "][b]" + players.keys()[TURN] + "[/b][/color]:"
	%question.text = question
	freshQuestions[TOPIC.to_lower()].erase(question)

var answer_prefixes = [
	"I think it's %s!",
	"It's %s!",
	"I'll say %s.",
]

func answer_question(cmd_info : CommandInfo, parameters : PackedStringArray):
	if !is_stopped:
		var answer = Array(parameters)[0]
		if cmd_info != null:
			var command_sender = cmd_info.sender_data.tags["display-name"]
			if players.keys().find(command_sender) == -1: return
			if players.keys()[TURN] != command_sender: return
		var player = players[players.keys()[TURN]]
		
		var num_ans = letters.find(answer.to_upper())
		if num_ans == -1: return
		
		var answer_msg = answer_prefixes.pick_random() % answer.to_upper()
		%message.text = answer_msg
		SoundHandler.tts(answer_msg)
		
		is_stopped = true
		await suspense(answer)
		if ansLetter == answer.to_upper():
			print(answer + " is correct!")
			player.points += 100
			player.TRIVITIME.answer_history.append(true)
			SoundHandler.play_sfx("res://assets/sfx/trivitime/correct.wav")
			# %players.find_child(command_sender).find_child("Animations").play("correct")
			await wait(0.3)
			%message.text = "Woohoo!"
			SoundHandler.tts("Woohoo!")
		else:
			print(answer + " is incorrect!")
			player.points -= 50
			player.TRIVITIME.answer_history.append(false)
			SoundHandler.play_sfx("res://assets/sfx/trivitime/incorrect.wav")
			await wait(0.3)
			%message.text = "No!"
			SoundHandler.tts("No!")
			# %players.find_child(command_sender).find_child("Animations").play("incorrect")
		await wait(0.7)
		TURN = (TURN + 1 % len(players))
		update()
		is_stopped = false
		newQuestion()
	else: print("Game is stopped!")

func think(senderdata : SenderData, msg : String):
	var command_sender = senderdata.tags["display-name"]
	if players.keys()[TURN] != command_sender: return
	if msg.begins_with("!"): return
	
	%message.text = msg
	SoundHandler.tts(msg)


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

func shuffleList(list : Array):
	var shuffledList = []
	var unused = list
	for i in range(list.size()):
		var item = unused.pick_random()
		shuffledList.append(item)
		unused.erase(item)
	return shuffledList

func suspense(ans):
	var chosen : Button = %Answers.find_child("Button" + ans.to_upper())
	
	for button : Button in %Answers.get_children():
		if button.name != chosen.name:
			print(button.button_mask)
			button.modulate = Color("ffffff82")
	
	await SoundHandler.play_sfx("res://assets/sfx/heartbeat_loop.mp3", 2)

func vote(cmd_info : CommandInfo, parameters : PackedStringArray):
	var command_sender = cmd_info.sender_data.tags["display-name"]
	var answer = Array(parameters)[0]
	if players.keys()[TURN] == command_sender: return
	print("Voting..")
	var num_ans = letters.find(answer.to_upper())
	
	if num_ans == - 1: return
	
	if voters.keys().find(command_sender) != -1:
		var old_vote = voters[command_sender]
		votes[old_vote] -= 1
	else:
		total_votes += 1
	voters[command_sender] = num_ans
	votes[num_ans] += 1
	

func update_votes():
	pass
	#var pos = 0
	#for button : Button in %Answers.get_children():
		#var line : Line2D = button.get_child(2)
		#
		#var vote_percent : float = 0.00
		#if total_votes != 0: 
			#vote_percent = float(votes[pos]) / total_votes
		#
		#var length = vote_percent * 850
		#
		#if line.get_point_count() < 2:
			#line.add_point(Vector2(250, 0))
			#line.add_point(Vector2(0, 0))
			#
		#line.set_point_position(1, Vector2(length / 2, 0))
		#line.set_point_position(2, Vector2(-length / 2, 0))
		#
		#pos += 1

func wait(sec : float):
	await get_tree().create_timer(sec).timeout
