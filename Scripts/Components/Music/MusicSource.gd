class_name MusicSource extends VariationComponent

var path := "": set = set_path
var audio: AudioStream
var use_bgm := false:
	set(value):
		use_bgm = value
		for bgm: BGMBlock in bgm_blocks:
			bgm.visible = use_bgm

@export_group("Nodes")
@export var label: Label
@export var listen_button: TextureButton
@export var preview_bgm_button: TextureButton
@export var bgm_blocks: Array[BGMBlock] = []

func set_path(value: String) -> void:
	path = value
	label.text = "Source: " + path
	use_bgm = path.get_extension() == "bgm"
	if use_bgm:
		var json := Global.read_json(get_full_path())
		bgm_blocks[0].apply_json(Global.get_value_of_type(json, "Normal", TYPE_DICTIONARY))
		bgm_blocks[1].apply_json(Global.get_value_of_type(json, "Hurry", TYPE_DICTIONARY))
		audio = null
	else:
		var full_path := get_full_path()
		if FileAccess.file_exists(full_path):
			audio = Global.load_audio(full_path)
			if audio:
				audio.resource_name = path.get_file()
			else:
				MessageLog.log_error("Invalid audio.", self)
		else:
			audio = null
			MessageLog.log_error("Audio not found: " + path, self)
	listen_button.visible = audio != null
	preview_bgm_button.visible = use_bgm

func select_file(file_path: String) -> void:
	path = Global.remove_directory(file_path, Global.music_path.get_base_dir())

func listen() -> void:
	AudioPlayer.open(audio)

func preview_bgm() -> void:
	JSONPreview.open(get_bgm())

func save_bgm() -> void:
	if use_bgm and path:
		Global.write_json(get_full_path(), get_bgm(), false)

func get_full_path() -> String:
	return Global.music_path.get_base_dir().path_join(path)

func get_json(_remove_redundant := true) -> Dictionary:
	return {"source": path}

func apply_json(json: Dictionary) -> void:
	if json.has("source"):
		path = Global.get_value_of_type(json, "source", TYPE_STRING, self)
	else:
		MessageLog.log_warning("No source given.", self)

func get_bgm() -> Dictionary:
	var json := bgm_blocks[0].get_json()
	json.merge(bgm_blocks[1].get_json())
	return json
