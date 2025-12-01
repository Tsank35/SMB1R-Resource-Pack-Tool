extends ScrollContainer

@export var path_display: LineEdit
@export var root_variation: VariationBlock

func select_file(path: String, apply := true) -> void:
	Global.music_path = path
	path_display.text = Global.remove_directory(path, Global.directory.path_join("Audio/BGM"))
	if apply:
		var json := Global.read_json(path)
		if json.has("variations"):
			root_variation.apply_json(json.variations)
		else:
			root_variation.clear_component()

func preview_json() -> void:
	JSONPreview.open(root_variation.get_json())

func save() -> void:
	if not Global.music_path:
		MessageLog.log_error("No file set. Import a file or create a new one.")
		return
	Global.write_json(Global.music_path, root_variation.get_json())
	MessageLog.log_message("Saved " + Global.music_path.get_file() + ".")
	for source: Node in get_tree().get_nodes_in_group("Music Sources"):
		if source is MusicSource:
			source.save_bgm()

func _process(_delta) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("save"):
		save()
