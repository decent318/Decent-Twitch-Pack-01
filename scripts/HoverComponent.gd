class_name HoverComponent
extends Node

@export var HoverLength := 0.50
@export var Translate := Vector2.ZERO
@export var Scale := 1.0
@export_range(-360, 360) var Rotation := 0

@export var active_when_disabled := true

@export_file("*mp3", "*.wav") var Hover_SFX = "res://assets/sfx/hover.wav"
@export_file("*mp3", "*.wav") var Unhover_SFX

@export_group("Styling", "style")
@export var style_easing : Tween.EaseType = Tween.EASE_IN
@export var style_transition : Tween.TransitionType = Tween.TRANS_LINEAR

@export var default_position : bool = true

var button : Button
var def_but_pos : Vector2
var def_but_scale : Vector2
var def_but_rot : float
func _ready():
	button = get_parent()
	
	await get_tree().process_frame
	def_but_pos = button.position
	def_but_scale = button.scale
	def_but_rot = button.rotation
	
	button.pivot_offset = Vector2(button.size.x / 2, button.size.y / 2)
	get_parent().mouse_entered.connect(onHover)
	get_parent().mouse_exited.connect(unHover)

func _exit_tree():
	button.disconnect("mouse_entered", onHover)
	button.disconnect("mouse_exited", unHover)

func _process(delta):
	if !default_position:
		def_but_pos = button.position
		def_but_scale = button.scale
		def_but_rot = button.rotation

func onHover():
	if !button.disabled or active_when_disabled:
		MusicHandler.play_sfx(str(Hover_SFX))
		
		create_tween().set_parallel(true)
		create_tween().tween_property(button, "position", def_but_pos + Translate, HoverLength).set_ease(style_easing).set_trans(style_transition)
		create_tween().tween_property(button, "scale", def_but_scale * Scale, HoverLength).set_ease(style_easing).set_trans(style_transition)
		create_tween().tween_property(button, "rotation", Rotation, HoverLength).set_ease(style_easing).set_trans(style_transition)

func unHover():
	if !button.disabled or active_when_disabled:
		MusicHandler.play_sfx(str(Unhover_SFX))
	
		create_tween().set_parallel(true)
		create_tween().tween_property(button, "position", def_but_pos - Translate, HoverLength).set_ease(style_easing).set_trans(style_transition)
		create_tween().tween_property(button, "scale", def_but_scale, HoverLength).set_ease(style_easing).set_trans(style_transition)
		create_tween().tween_property(button, "rotation", Rotation, HoverLength).set_ease(style_easing).set_trans(style_transition)
