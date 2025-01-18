extends Control

var point_pos
func _process(_delta: float) -> void:
	var screen_center = Vector2(get_viewport().content_scale_size.x / 2, get_viewport().content_scale_size.y / 2)
	$Line2D.position = screen_center
	point_pos = $Line2D.get_point_position(1)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if hovered_game != "":
			%games_container.find_child(hovered_game).modulate = "ffffff"
			selected_game = hovered_game
		var mouse_to_point_pos = Vector2(get_local_mouse_position().x - screen_center.x, get_local_mouse_position().y - screen_center.y)
		$Line2D.set_point_position(1, lerp(point_pos, mouse_to_point_pos, 0.2))
	else:
		if selected_game != "":
			match selected_game:
				"tt": SceneTransition.change_scene_close("res://scenes/trivitime/tt_config.tscn", Color.BLACK)
		else:
			$Line2D.set_point_position(1, lerp(point_pos, Vector2.ZERO, 0.2))

var hovered_game : String = ""
var selected_game : String = ""
func _ready() -> void:
	for child : Button in %games_container.get_children():
		child.modulate = "ffffff82"
		child.connect("mouse_entered", func():
			hovered_game = child.name
		)
		child.connect("mouse_exited", func():
			child.modulate = "ffffff82"
			selected_game = ""
			hovered_game = ""
		)
