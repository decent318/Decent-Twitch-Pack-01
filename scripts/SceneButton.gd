extends Button

@export_file("*.tscn") var Scene 
@export var color : Color 

func _ready():
	pressed.connect(change_scene)

func change_scene():
	MusicHandler.play_sfx("res://assets/sfx/click.wav")
	SceneTransition.change_scene_close(Scene, color)

func hover():
	MusicHandler.play_sfx("res://assets/sfx/hover.wav")
