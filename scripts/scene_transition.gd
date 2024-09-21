extends CanvasLayer

func change_scene_close(file, color):
	%Left.modulate = color
	%Right.modulate = color
	%Close.play("close")
	await %Close.animation_finished
	get_tree().change_scene_to_file(file)
	%Close.play_backwards("close")

func transition_callable_close(callable : Callable, color):
	%Left.modulate = color
	%Right.modulate = color
	%Close.play("close")
	await %Close.animation_finished
	callable.call()
	%Close.play_backwards("close")
