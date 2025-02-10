extends Control

func _ready():
	Global.load_twitch()
	Global.setup_twitch()
	SoundHandler.fade(0, 0, 0)
	SoundHandler.fade(0, 1.0, 0.5)
	SoundHandler.start_track("res://assets/music/title music - gotta go.mp3", 0, 1.0, true, false)
	#if Global.channel == "":
		#%Options.get_child(2).modulate = "ffffff"
	#else:
		#%Options.get_child(2).modulate = "ffffff00"

func trivitime():
	panel_index = 0
	update_panels()
	
func options():
	panel_index = 1
	update_panels()
	
func credits():
	panel_index = 2
	update_panels()
	
func leaderboard():
	panel_index = 3
	update_panels()
	
func updatelog():
	panel_index = 4
	update_panels()
	
func exit():
	SceneTransition.transition_callable_close(func(): 
		# Function 
		get_tree().quit(), 
		"#fffff") # Color

var old_panel = 0
var panel_index = 0
var panel : Panel

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released("scroll_up") or Input.is_action_just_pressed("up"):
		panel_index -= 1
	elif Input.is_action_just_released("scroll_down") or Input.is_action_just_pressed("down"):
		panel_index += 1
	else:
		return
	if panel_index != clamp(panel_index, 0, 4): 
		panel_index = clamp(panel_index, 0, 4)
		return
	panel_index = clamp(panel_index, 0, 4)
	update_panels()

func update_panels():
	panel = %panels.get_child(panel_index)
	var tween_time = min(abs(old_panel - panel_index), 3.5)
	old_panel = panel_index
	create_tween().tween_property(%panels, "position", Vector2(1061, 249 - panel.position.y), tween_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
