extends Control

func _ready():
	if Global.channel != "":
		%channel.text = Global.channel
		
	for resolution : Button in %resolutions.get_children():
		resolution.pressed.connect(set_resolution.bind(resolution.name))

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
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

func fullscreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	

var resolutions = {
	"3840x2160": Vector2(3840, 2160),
	"2560x1440": Vector2(2560, 1440),
	"1920x1080": Vector2(1920, 1080),
	"1336x768": Vector2(1336, 768),
	"1280x720": Vector2(1280, 720),
	"1440x900": Vector2(1440, 900),
	"1600x900": Vector2(1600, 900),
	"1024x600": Vector2(1024, 600),
	"800x600": Vector2(800, 600),
}

var old_resolution : String = "1920x1080"
var current_resolution : String = "1920x1080"
func set_resolution(resolution_string : String):
	if resolution_string != "OK":
		var resolution = resolutions[resolution_string]
		current_resolution = resolution_string
		get_window().size = resolution
		center_window()
		%reset_timer.start()
		%OK.disabled = false
		
func accept_resolution():
	%reset_timer.stop()
	%OK.disabled = true
	%OK.text = "OK"
	old_resolution = current_resolution

func _process(_delta):
	if !%reset_timer.is_stopped():
		%OK.text = "OK [" + str(floor(%reset_timer.time_left)) + "]"

func reset_timeout():
	%reset_timer.stop()
	%OK.disabled = true
	%OK.text = "OK"
	current_resolution = old_resolution
	%resolutions.find_child(current_resolution).button_pressed = true
	var resolution = resolutions[current_resolution]
	get_window().size = resolution
	center_window()

func center_window():
	var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().position = screen_center - window_size / 2
