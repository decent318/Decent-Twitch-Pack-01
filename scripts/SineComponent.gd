class_name SineComponent
extends Node

@export_subgroup("X")
@export var XSine : bool
@export var XFrequency : float = 5
@export var XAmplitude : float = 1
@export_subgroup("Y")
@export var YSine : bool
@export var YFrequency : float = 5
@export var YAmplitude : float = 1

var sine = randf_range(0.00, 1.00)
func _process(delta):
	sine += delta
	if XSine:
		get_parent().position.x += sin(sine * XFrequency) * XAmplitude
	if YSine:
		get_parent().position.y += sin(sine * YFrequency) * YAmplitude
