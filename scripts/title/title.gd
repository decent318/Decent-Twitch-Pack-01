extends Control

func _ready():
	if Global.channel == "":
		%Options.get_child(2).modulate = "ffffff"
	else:
		%Options.get_child(2).modulate = "ffffff00"

func play():
	SceneTransition.change_scene_close("res://scenes/title/games.tscn", "#fffff")
	
func options():
	SceneTransition.change_scene_close("res://scenes/title/options.tscn", "#fffff")
	
func credits():
	SceneTransition.change_scene_close("res://scenes/title/credits.tscn", "#fffff")
	
func updatelog():
	pass
	
func exit():
	SceneTransition.transition_callable_close(func(): 
		# Function 
		get_tree().quit(), 
		"#fffff") # Color
