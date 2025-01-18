extends Control

var client_id : String = Global.client_id 
var channel : String = Global.channel
var bot_username : String = Global.bot_username

var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection
var eventsub : TwitchEventSubConnection
var cmd_handler : GIFTCommandHandler = GIFTCommandHandler.new()
var iconloader : TwitchIconDownloader

var playersScore

var sortedPlayers

var player_report = 0

var number_suffixes = [
	"st",
	"nd",
	"rd",
	"th"
]
	

var grades = {
	95: "a+",
	90: "a",
	85: "b+",
	80: "b",
	75: "c+",
	70: "c",
	65: "d+",
	60: "d",
	55: "f",
	0: "f-"
}

var award_desc = {
	"a+": "Awarded for getting a accuracy of 95% or more.",
	"a": "Awarded for getting a accuracy of 90% or more.",
	"b+": "Awarded for getting a accuracy of 85% or more.",
	"b": "Awarded for getting a accuracy of 80% or more.",
	"c+": "Awarded for getting a accuracy of 75% or more.",
	"c": "Awarded for getting a accuracy of 70% or more.",
	"d+": "Awarded for getting a accuracy of 65% or more.",
	"d": "Awarded for getting a accuracy of 60% or more.",
	"f": "Awarded for getting a accuracy of 55% or more.",
	"f-": "Awarded for getting a accuracy of 54% or less.",
	"perfect": "Awarded for not missing a single question.",
	"guillible": "Awarded for missing the most questions.",
	"frontrunner": "Awarded for winning with a lead of at least 300 points.",
	"hotshot": "Awarded for having the highest streak."
}

var awards = {}

var leaderboard = Leaderboard.new()

var lowst_percent = ""
var highest_streak = ""
var percents = {}

func _ready():
	id = Global.id
	api = Global.api
	irc = Global.irc
	eventsub = Global.eventsub
	cmd_handler = Global.cmd_handler
	iconloader = Global.iconloader
	
	irc.chat_message.connect(tts_podium)
	
	playersScore = leaderboard.return_leaderboard(0)
	sortedPlayers = playersScore.keys()
	print(playersScore)
	
	for plr in playersScore:
		var ans_history : Array = Global.players[plr].TRIVITIME.answer_history
		var correct = 0
		for prc in ans_history: 
			if prc: correct += 1
		var percent = round(float(correct) / float(len(ans_history)) * 100)
		percents[plr] = percent
		print("AAA")
		print(percents)
	
	update_report()


func update_report():
	var plr_name = sortedPlayers[player_report]
	var plr_place = sortedPlayers.find(plr_name) + 1
	var plr_score = Global.players[plr_name].points
	var ans_history : Array = Global.players[plr_name].TRIVITIME.answer_history
	var correct = 0
	for prc in ans_history: 
		if prc: correct += 1
	var percent = round(float(correct) / float(len(ans_history)) * 100)
	%username.text = plr_name
	%place.text = str(plr_place) + number_suffixes[min(plr_place - 1, 3)]
	%score.text = str(plr_score) + " points."
	%percent.text = str(percent) + "% (" + str(correct) + "/" + str(len(ans_history)) + ")"
	
	# AWARDS
	
	# GRADE AWARDS
	var pos = 0
	for grade : int in grades.keys():
		if percent >= grade: break
		pos += 1
	
	awards = {}
	var grade = grades.values()[pos]
	awards[grade] = {"desc": award_desc[grade], "image": grade + ".png"}
	
	# REMOVES UNNECESSARY LEADERBOARD CALCULATIONS
	if lowst_percent == "":
		print(percents)
		var percentSort = leaderboard.return_leaderboard(-1, "", "", percents).keys()
		lowst_percent = percentSort[len(sortedPlayers) - 1]
	
	if highest_streak == "":
		var streakSort = leaderboard.return_leaderboard(0, "streak", "TRIVITIME").keys()
		highest_streak = streakSort[0]
		
	# GUILLIBLE
	if lowst_percent == plr_name:
		awards["guillible"] = {"desc": award_desc["guillible"], "image": "guillible.png"}
		
	# HOTSHOT
	if highest_streak == plr_name:
		awards["hotshot"] = {"desc": award_desc["hotshot"], "image": "hotshot.png"}
		
	# PERFECT
	if percent == 100:
		awards["perfect"] = {"desc": award_desc["perfect"], "image": "perfect.png"}
		
	# FRONTRUNNER
	if len(sortedPlayers) > 1:
		if playersScore[sortedPlayers[0]] - playersScore[sortedPlayers[1]] >= 300 and sortedPlayers[0] == plr_name:
			awards["frontrunner"] = {"desc": award_desc["frontrunner"], "image": "frontrunner.png"}
	
	for award in %awards.get_children(): # GET RID OF ANY AWARDS NO LONGER NEEDED
		if awards.keys().find(award.name.to_lower()) == -1: award.queue_free()
	
	for award : String in awards:
		var t_award = %temp_award.duplicate()
		var hbox = t_award.get_child(0)
		var icon : TextureRect = hbox.get_child(0).get_child(0)
		var title : Label = hbox.get_child(1).get_child(0)
		var desc : Label =  hbox.get_child(1).get_child(1)
		
		if %awards.find_child(award.to_upper(), false, false) != null: continue 
		
		t_award.name = award.to_upper()
		title.text = award.to_upper()
		desc.text = awards[award].desc
		icon.texture = load("res://assets/sprites/trivitime/awards/" + awards[award].image)
		
		%awards.add_child(t_award)
		
	print(awards)


func new_players():
	Global.players = {}
	SceneTransition.change_scene_close("res://scenes/trivitime/tt_players.tscn", "#598647")

func same_players():
	for plr in Global.players:
		Global.players[plr].points = 0
		Global.players[plr].supporters = []
		Global.players[plr].streak = 0
		Global.players[plr].ans_times = []
	SceneTransition.change_scene_close("res://scenes/trivitime/tt_questions.tscn", "#598647")

var allowed_voices = false

func tts_podium(senderdata : SenderData, msg : String):
	var sender = senderdata.tags["display-name"]
	print(sortedPlayers.find(sender))
	if (sortedPlayers.find(sender) <= 2 and sortedPlayers.find(sender) != -1) or allowed_voices:
		if !msg.begins_with("!"):
			DisplayServer.tts_speak(msg, "", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Voices"))) * 100)


func next_person() -> void:
	player_report = (player_report + 1) % len(sortedPlayers)
	update_report()

func previous_person() -> void:
	player_report = (player_report - 1) % len(sortedPlayers)
	update_report()
