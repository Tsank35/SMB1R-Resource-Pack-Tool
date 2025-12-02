extends ScrollContainer

@export var path_display: LineEdit
@export var root_variation: VariationBlock
@export var bgm_blocks: Array[BGMBlock] = []

func select_file(path: String, apply := true) -> void:
	Global.music_path = path
	path_display.text = Global.remove_directory(path, Global.directory.path_join("Audio/BGM"))
	
	var editing_bgm := path.get_extension() == "bgm"
	root_variation.visible = not editing_bgm
	for bgm: BGMBlock in bgm_blocks:
		bgm.visible = editing_bgm
	
	if apply:
		var json := Global.read_json(path)
		if editing_bgm:
			bgm_blocks[0].apply_json(Global.get_value_of_type(json, "Normal", TYPE_DICTIONARY))
			bgm_blocks[1].apply_json(Global.get_value_of_type(json, "Hurry", TYPE_DICTIONARY))
		elif json.has("variations"):
			root_variation.apply_json(Global.get_value_of_type(json, "variations", TYPE_DICTIONARY))
		else:
			root_variation.clear_component()

func preview_json() -> void:
	JSONPreview.open(get_json())

func save() -> void:
	if not Global.music_path:
		MessageLog.log_error("No file set. Import a file or create a new one.")
		return
	
	Global.write_json(Global.music_path, get_json())
	MessageLog.log_message("Saved " + Global.music_path.get_file() + ".")
	
	if not Global.music_path.get_extension() == "bgm":
		for source: Node in get_tree().get_nodes_in_group("Music Sources"):
			if source is MusicSource:
				source.save_bgm()

func _process(_delta) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("save"):
		save()

func get_json() -> Dictionary:
	if Global.music_path.get_extension() == "bgm":
		var json := bgm_blocks[0].get_json()
		json.merge(bgm_blocks[1].get_json())
		return json
	return root_variation.get_json()
