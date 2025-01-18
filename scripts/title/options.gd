extends Control

func _ready():
	if Global.channel != "":
		%channel.text = Global.channel

var sine := 0.0
var gear_speed = 0.05
func _process(delta):
	sine += delta
	%gear.rotation += (sin(sine)) * gear_speed

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
	%channel.text = removeBannedCharacters(x, [" ", ".", "!", "?", ",", "/", "|", "\\", "*", "%", "&", "+", "-"])
	Global.channel = x

func add_to_blacklist():
	pass


func screen_mode_changed(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	


func gear_hover() -> void:
	gear_speed = 0.1

func gear_unhover() -> void:
	gear_speed = 0.05
