extends Slider

@export var bus_name: String

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	update()
	
func _on_value_changed(new_value : float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(new_value)
	)
	
func update():
	create_tween().tween_property($".", "value", db_to_linear(AudioServer.get_bus_volume_db(bus_index)), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
