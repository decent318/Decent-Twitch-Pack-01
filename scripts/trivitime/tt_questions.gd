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
	MusicHandler.start_track("res://assets/music/Guesstimation.wav")
	
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
	
	irc.chat_message.connect(cmd_handler.handle_command)
	irc.whisper_message.connect(cmd_handler.handle_command.bind(true))
	
	QUESTIONS_PER_PERSON = floor(float(LENGTH_OF_GAME) / float(len(players))) * floor(60.0 / float(SECONDS_PER_ANSWER))
	TOTAL_QUESTIONS = QUESTIONS_PER_PERSON * len(players)
	
	TOTAL_QUESTIONS = get_nearest_multiple(TOTAL_QUESTIONS, len(players))
	QUESTIONS_PER_PERSON = TOTAL_QUESTIONS / len(players)
	
	var INTERMISSION_INTERVAL = ceil(float(TOTAL_QUESTIONS) / float(INTERMISSIONS))
	INTERMISSION_INTERVAL = get_nearest_multiple(INTERMISSION_INTERVAL, len(players))
	
	INTERMISSION_INTERVALS = [0]
	var pos = 0
	for intermission in INTERMISSIONS:
		print(INTERMISSION_INTERVAL)
		INTERMISSION_INTERVALS.append(INTERMISSION_INTERVAL + INTERMISSION_INTERVALS[pos])
		pos += 1
	INTERMISSION_INTERVALS.remove_at(0)
	print(INTERMISSION_INTERVALS)
	
	displayPlayers()
	newQuestion()
	
	for ans : Button in %Answers.get_children():
		ans.pressed.connect(
			func():
				answer_question(null, [ans.name.substr(6,1)])
		)


var QUESTIONS_PER_PERSON : int
var TOTAL_QUESTIONS : int

var INTERMISSIONS := TriviTime.INTERMISSIONS
var INTERMISSION_INTERVALS = []

var SECONDS_PER_ANSWER := TriviTime.SECONDS_PER_ANSWER # THE AMOUNT OF SECONDS A PLAYER HAS TO ANSWER A QUESTION
var LENGTH_OF_GAME := TriviTime.LENGTH_OF_GAME # THE MAX LENGTH OF THE GAME IN MINUTES
var CURRENT_QUESTION := 0 # THE CURRENT QUESTION
var TOPIC := "HISTORY" # THE CURRENT TOPIC

var TURN = 0

func get_nearest_multiple(x: int, step: int) -> float:
	var remainder = x % step
	if remainder < step / 2:
		return x - remainder
	else:
		return x + (step - remainder)

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

func setup_minileaderboard(guy : TextureRect, place : int, sortedPlayers):
	if place > len(sortedPlayers) - 1: 
		guy.visible = false
		return
	else:
		guy.visible = true
	var plr_name = sortedPlayers[place]
	guy.get_child(0).text = plr_name
	guy.get_child(1).text = str(Global.players[plr_name].points)

func newQuestion():
	if CURRENT_QUESTION >= TOTAL_QUESTIONS:
		question_num.text = "GAME OVER"
		SceneTransition.change_scene_close("res://scripts/trivitime/tt_results.gd", "#598647")
		return
		
	# INTERMISSION
	if INTERMISSION_INTERVALS[0] == CURRENT_QUESTION: 
		is_stopped = true
		INTERMISSION_INTERVALS.pop_front()
		var tick_sfx = preload("res://assets/sfx/trivitime/wheel tick.mp3")
		question_num.text = "INTERMISSION"
		
		var leaderboard = Leaderboard.new()
		var sortedPlayers = leaderboard.return_leaderboard(0).keys()
		
		setup_minileaderboard(%first, 0, sortedPlayers)
		setup_minileaderboard(%second, 1, sortedPlayers)
		setup_minileaderboard(%third, 2, sortedPlayers)
		
		%SceneAnimations.play("intermission")
		
		freshQuestions.erase(TOPIC.to_lower())
		var topics : Array = freshQuestions.keys()
		var new_topic = topics.pick_random()
		
		%TOPIC.text = TOPIC.to_upper()
		
		for i in range(15):
			%TOPIC.text = topics[i % len(topics)].to_upper()
			await wait(0.05 * i)
			MusicHandler.play_sfx_from_preload(tick_sfx)
			
		TOPIC = new_topic
		%TOPIC.text = TOPIC.to_upper()
		MusicHandler.play_sfx("res://assets/sfx/trivitime/woohoo.mp3")
		await wait(1.5)
		%TOPIC.text = ""
		%SceneAnimations.play_backwards("intermission")
		is_stopped = false
	
	CURRENT_QUESTION += 1
	votes = [0, 0, 0, 0]
	total_votes = 0
	update_votes()
	
	for button : Button in %Answers.get_children():
		button.modulate = Color("ffffff")
	
	question_num.text = "QUESTION #" + str(CURRENT_QUESTION)
	
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
	%question.text = players.keys()[TURN] + ", " + question
	freshQuestions[TOPIC.to_lower()].erase(question)

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
		
		is_stopped = true
		await suspense(answer)
		if ansLetter == answer.to_upper():
			print(answer + " is correct!")
			player.points += 100
			player.TRIVITIME.answer_history.append(true)
			# %players.find_child(command_sender).find_child("Animations").play("correct")
		else:
			print(answer + " is incorrect!")
			player.points -= 50
			player.TRIVITIME.answer_history.append(false)
			# %players.find_child(command_sender).find_child("Animations").play("incorrect")
		TURN = (TURN + 1 % len(players))
		update()
		is_stopped = false
		newQuestion()
	else: print("Game is stopped!")

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
	
	await MusicHandler.play_sfx("res://assets/sfx/heartbeat_loop.mp3", 2)

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
	
	update_votes()

func update_votes():
	var pos = 0
	for button : Button in %Answers.get_children():
		var line : Line2D = button.get_child(2)
		
		var vote_percent : float = 0.00
		if total_votes != 0: 
			vote_percent = float(votes[pos]) / total_votes
		
		var length = vote_percent * 850
		
		if line.get_point_count() < 2:
			line.add_point(Vector2(250, 0))
			line.add_point(Vector2(0, 0))
			
		line.set_point_position(1, Vector2(length / 2, 0))
		line.set_point_position(2, Vector2(-length / 2, 0))
		
		pos += 1

func wait(sec : float):
	await get_tree().create_timer(sec).timeout
