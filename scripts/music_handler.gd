extends Node

@export var MusicBus : String = "Music"
@export var SFXBus : String = "SFX"

func start_track(path : String, channel := 0, volume : float = 1.00, loop : bool = true, override : bool = true, bus : String = MusicBus):
	var stream_player : AudioStreamPlayer = %Channels.get_child(channel)
	var audio_stream = load(path)
	if !override:
		if stream_player.playing and stream_player.stream == audio_stream:
			return
	stream_player.stream = audio_stream
	stream_player.volume_db = linear_to_db(volume)
	if loop:
		if !stream_player.is_connected("finished", play_song):
			stream_player.connect("finished", play_song.bind(stream_player))
	else:
		if stream_player.is_connected("finished", play_song):
			stream_player.disconnect("finished", play_song.bind(stream_player))
	stream_player.bus = MusicBus
	
	play_song(stream_player)
	
func play_song(channel : AudioStreamPlayer):
	channel.play()

func stop_song(channel := 0):
	var stream_player : AudioStreamPlayer = %Channels.get_child(channel)
	stream_player.stop()

func pause_song(paused := true, channel := 0):
	var stream_player : AudioStreamPlayer = %Channels.get_child(channel)
	stream_player.stream_paused = paused

func play_sfx(path, volume = 1.0, loops = 1, bus : String = SFXBus):
	var stream_player : AudioStreamPlayer = AudioStreamPlayer.new()
	%SFX.add_child(stream_player)
	var audio_stream = load(path)
	stream_player.stream = audio_stream
	stream_player.volume_db = linear_to_db(volume)
	stream_player.bus = bus
	for i in loops:
		stream_player.play()
		await stream_player.finished

func add_effect(bus : String, effect : AudioEffect, override : bool = false):
	var bus_index = AudioServer.get_bus_index(bus)
	if !override:
		for i in AudioServer.get_bus_effect_count(bus_index):
			if AudioServer.get_bus_effect(bus_index, i).is_class(effect.get_class()):
				return
	AudioServer.add_bus_effect(bus_index, effect)
