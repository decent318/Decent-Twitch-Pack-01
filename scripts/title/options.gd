extends Control

func _ready():
	if Global.channel != "":
		%channel.text = Global.channel

func removeBannedCharacters(x:String, chars):
	var new_x = ""
	for character in chars:
		new_x = x.replace(character, "")
		x = new_x
	return new_x

func expand_channel(_x):
	if %channel.text == "":
		create_tween().tween_property(%channel, "size", Vector2(167, 40), 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	else:
		create_tween().tween_property(%channel, "size", Vector2(311, 40), 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func submit_channel(x:String):
	var new_channel = removeBannedCharacters(x, [" ", ".", "!", "?", ",", "/", "|", "\\", "*", "%", "&", "+", "-"])
	%channel.text = new_channel
	Global.channel = new_channel

func add_to_blacklist():
	pass


func windowed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func fullscreen():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
