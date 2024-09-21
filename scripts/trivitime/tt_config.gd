extends Control

var gamemodes = GameManager.GAME_MODES.keys()

var DESCRIPTIONS = {
	0: "Guess the correct answer in between 3 fakes!",
	1: "Guess the correct answer(s) and dodge the fakes! ",
	2: "Guess the exact answer, no fakes."
}

func _ready():
	var pos = 0
	for gamemode in gamemodes:
		%Gamemode.add_item(gamemode, pos)
		pos += 1
	
	%rounds.text = str(GameManager.MaxRounds)
	%Gamemode.get_child(1).text = DESCRIPTIONS[%Gamemode.selected]
	
	MusicHandler.start_track("res://assets/music/trivitime_theme.mp3")
	update()

func _process(delta):
	%recap.position

func change_round(new_txt = %rounds.text):
	var new_round = %rounds.text
	%rounds.text = str(clamp(int(new_round), 1, 99))
	var suffix = "Rounds"
	if int(str(clamp(int(new_round), 1, 99))) == 1:
		suffix = "Round"
	%rounds.get_child(0).text = suffix
	GameManager.MaxRounds = int(str(clamp(int(new_round), 1, 99)))
	update()

func change_gamemode(index = 0):
	GameManager.GAME_MODE = index
	%Gamemode.get_child(1).text = DESCRIPTIONS[index]
	update()

func backup_change_round():
	var new_round = %rounds.text
	%rounds.text = str(clamp(int(new_round), 1, 99))
	var suffix = "Rounds"
	if int(str(clamp(int(new_round), 1, 99))) == 1:
		suffix = "Round"
	%rounds.get_child(0).text = suffix
	GameManager.MaxRounds = int(str(clamp(int(new_round), 1, 99)))
	update()

func update():
	var gamemode = ""
	var suffix = "ROUNDS"
	if GameManager.MaxRounds == 1:
		suffix = "ROUND"
		
	%settings_recap.text = "GAME IS SET TO " + GameManager.GAME_MODES.keys()[%Gamemode.selected] + " FOR " + str(GameManager.MaxRounds) + " ROUNDS."

var settings_opened = false
func reveal_settings():
	MusicHandler.play_sfx("res://assets/sfx/woosh-230554.mp3")
	if settings_opened:
		create_tween().tween_property(%"game settings", "position", Vector2(-579, 48), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	else:
		create_tween().tween_property(%"game settings", "position", Vector2(26, 48), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	settings_opened = not settings_opened


func prompt_upload():
	%UploadDialog.visible = true

func upload(path : String):
	GameManager.Questions = JSON.parse_string(FileAccess.get_file_as_string(path))
	var filenameLabel = %questionStuff.get_child(0)
	var filedescLabel = %questionStuff.get_child(1)
	
	filenameLabel.text = path.get_file()
	filedescLabel.text = GameManager.Questions.format.to_upper() + " / " + str(len(GameManager.Questions.questions)) + " QUESTIONS"
	
