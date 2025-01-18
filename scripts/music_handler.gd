extends Node

signal mute

func _ready():
	%Track.play()

func pause(do_pause = true):
	%Track.stream_paused = pause

func _process(_delta):
	if Input.is_action_just_pressed("mute"):
		toggleMute()

func start_track(path, volume = 0.00):
	%Track.volume_db = volume
	var file = load(path)
	%Track.stop()
	%Track.stream = file
	%Track.play()

func loop():
	%Track.play()

func play_sfx(path, loops = 1):
	var sfx = AudioStreamPlayer.new()
	var file = load(path)
	sfx.bus = "SFX"
	sfx.stream = file
	add_child(sfx)
	for i in loops:
		sfx.play()
		await sfx.finished
	sfx.queue_free()

func play_sfx_from_preload(pload, loops = 1):
	var sfx = AudioStreamPlayer.new()
	sfx.bus = "SFX"
	sfx.stream = pload
	add_child(sfx)
	for i in loops:
		sfx.play()
		await sfx.finished
	sfx.queue_free()


var muted = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) == 0
func toggleMute():
	if muted:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(1.00))
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0.00))
	muted = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) == 0
	mute.emit()

func refreshMute():
	muted = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) == 0
