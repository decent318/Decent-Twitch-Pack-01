extends Button

@export_file("*.tscn") var Scene 
@export var color : Color 
@export var fade : bool = false
@export_group("fade", "f")
@export var f_fade_channel = 0
@export var f_fade_volume = 0.0
@export var f_fade_duration = 0.5
@export var f_fade_ease : Tween.EaseType = Tween.EASE_IN
@export var f_fade_transition : Tween.TransitionType = Tween.TRANS_LINEAR

func _ready():
	pressed.connect(change_scene)

func change_scene():
	SoundHandler.play_sfx("res://assets/sfx/click.wav")
	if fade: SoundHandler.fade(f_fade_channel, f_fade_volume, f_fade_duration, f_fade_ease, f_fade_transition)
	SceneTransition.change_scene_close(Scene, color)

func hover():
	SoundHandler.play_sfx("res://assets/sfx/hover.wav")
