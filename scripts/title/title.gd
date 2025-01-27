extends Control

func _ready():
	MusicHandler.start_track("res://assets/music/title music - gotta go.mp3", 0, 1.0, true, false)
	#if Global.channel == "":
		#%Options.get_child(2).modulate = "ffffff"
	#else:
		#%Options.get_child(2).modulate = "ffffff00"

func play():
	SceneTransition.change_scene_close("res://scenes/title/games.tscn", "#fffff")
	
func options():
	create_tween().tween_property(%panels, "position", Vector2(1061, 249), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	panel = 0
	
func credits():
	create_tween().tween_property(%panels, "position", Vector2(1061, -357), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	panel = 1
	
func leaderboard():
	create_tween().tween_property(%panels, "position", Vector2(1061, -963), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	panel = 2
	
func updatelog():
	create_tween().tween_property(%panels, "position", Vector2(1061, -1569), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	panel = 3
	
func exit():
	SceneTransition.transition_callable_close(func(): 
		# Function 
		get_tree().quit(), 
		"#fffff") # Color

var panel = 0

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("scroll_up") or Input.is_action_just_pressed("up"):
		panel -= 1
	if Input.is_action_just_released("scroll_down") or Input.is_action_just_pressed("down"):
		panel += 1
	panel = clamp(panel, 0, 3)
	create_tween().tween_property(%panels, "position", Vector2(1061, 249 - (606 * panel)), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
