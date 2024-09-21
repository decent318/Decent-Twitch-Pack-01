extends Control

func _ready():
	if GameManager.channel != "":
		%channel.text = GameManager.channel

func _process(delta):
	%gear.rotation += 2. * delta

func removeBannedCharacters(x:String, chars):
	var new_x = ""
	for character in chars:
		new_x = x.replace(character, "")
		x = new_x
	return new_x

func expand_channel(x):
	if %channel.text == "":
		create_tween().tween_property(%channel, "size", Vector2(167, 40), 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	else:
		create_tween().tween_property(%channel, "size", Vector2(311, 40), 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func submit_channel(x:String):
	%channel.text = removeBannedCharacters(x, [" ", ".", "!", "?", ",", "/", "|", "\\", "*", "%", "&", "+", "-"])
	GameManager.channel = x

func add_to_blacklist():
	pass
