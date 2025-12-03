class_name BGMBlock extends DataBlock

@export var source: MusicSource

var path := "": set = set_path
var audio: AudioStream

@export_group("Nodes")
@export var label: Label
@export var source_label: Label
@export var loop_input: SpinBox
@export var listen_button: TextureButton

func _ready() -> void:
	super()
	label.text = name

func set_path(value: String) -> void:
	path = value
	source_label.text = "Source: " + path
	if path:
		audio = Global.load_audio(Global.music_path.get_base_dir().path_join(path))
		if audio:
			audio.resource_name = path.get_file()
		else:
			MessageLog.log_error("Invalid audio.", source)
	else:
		audio = null
	listen_button.visible = audio != null

func select_file(file_path: String) -> void:
	path = Global.remove_directory(file_path, Global.music_path.get_base_dir())

func listen() -> void:
	AudioPlayer.open(audio, loop_input.value)

func get_json(_remove_redundant := true) -> Dictionary:
	return {
		name: {
			"source": path,
			"loop": loop_input.value
		}
	}

func apply_json(json: Dictionary) -> void:
	if json.has("source"):
		path = Global.get_value_of_type(json, "source", TYPE_STRING, source)
	else:
		path = ""
		MessageLog.log_warning("No source given.", source)
	loop_input.set_value_no_signal(Global.get_value_of_type(json, "loop", TYPE_INT, source))
