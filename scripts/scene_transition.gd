extends CanvasLayer

func change_scene_close(file, color):
	%Left.modulate = color
	%Right.modulate = color
	%Animations.play("close")
	await %Animations.animation_finished
	get_tree().change_scene_to_file(file)
	%Animations.play_backwards("close")

func transition_callable_close(callable : Callable, color):
	%Left.modulate = color
	%Right.modulate = color
	%Animations.play("close")
	await %Animations.animation_finished
	callable.call()
	%Animations.play_backwards("close")
