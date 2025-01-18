extends Control

func _ready():
	await Global.twitch_setup
	
	SceneTransition.change_scene_close("res://scenes/title/title.tscn", Color("000000"))
