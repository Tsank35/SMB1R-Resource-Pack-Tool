extends Window

var audio_length := 0.0

@export var slider: HSlider
@export var time: Label
@export var stream_player: AudioStreamPlayer

func open(audio: AudioStream, loop := -1.0) -> void:
	if not audio:
		MessageLog.log_error("No audio.")
		return
	title = audio.resource_name
	var stream := audio.duplicate()
	if loop >= 0:
		title += " (Loop: " + str(loop) + ")"
		if stream is AudioStreamWAV:
			stream.loop_begin = loop
		else:
			stream.loop = true
			stream.loop_offset = loop
	stream_player.stream = stream
	audio_length = stream.get_length()
	slider.max_value = audio_length
	popup_centered()

func play_or_stop() -> void:
	if stream_player.playing:
		stream_player.stop()
	elif slider.value < audio_length:
		stream_player.play(slider.value)
	else:
		stream_player.play()

func move_slider() -> void:
	if stream_player.playing:
		stream_player.stop()

func _process(_delta) -> void:
	var pos := 0.0
	if stream_player.playing:
		pos = stream_player.get_playback_position()
		slider.set_value_no_signal(pos)
	else:
		pos = slider.value
	time.text = format_time(pos) + "/" + format_time(audio_length)

func format_time(value: float) -> String:
	const MINUTE := 60.0
	var minutes := floori(value / MINUTE)
	var seconds := floori(value) % floori(MINUTE)
	if seconds < 10:
		return str(minutes) + ":0" + str(seconds)
	return str(minutes) + ":" + str(seconds)

func snap_slider_to_end() -> void:
	slider.set_value_no_signal(audio_length)

func close() -> void:
	stream_player.stop()
	stream_player.stream = null
	slider.value = 0
	audio_length = 0
	hide()
