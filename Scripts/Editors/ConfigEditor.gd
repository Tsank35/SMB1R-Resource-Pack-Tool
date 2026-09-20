extends ScrollContainer

const CONFIG_BLOCK := "res://Scenes/Components/Config/ConfigBlock.tscn"

@export var option_container: VBoxContainer

func _ready() -> void:
	Global.directory_changed.connect(update)

func update() -> void:
	clear()
	var path := Global.directory.path_join("config.json")
	if FileAccess.file_exists(path):
		var json := Global.read_json(path)
		var value_keys: Dictionary = Global.get_value_of_type(json, "value_keys", TYPE_DICTIONARY)
		var option_descs: Dictionary = Global.get_value_of_type(json, "option_descs", TYPE_DICTIONARY)
		for key in value_keys.keys():
			var data := {key: value_keys.get(key)}
			if option_descs.has(key):
				data._desc = option_descs[key]
			add_option(data)
		update_config()
	else:
		Global.config.clear()

func add_option(json := {}) -> void:
	var option: ConfigBlock = Global.instantiate(CONFIG_BLOCK)
	option_container.add_child(option)
	if json:
		option.apply_json(json)
		option.set_option_name(json.keys()[0])

func get_options() -> Array[ConfigBlock]:
	var options: Array[ConfigBlock] = []
	for child: Node in option_container.get_children():
		if child.is_queued_for_deletion():
			continue
		if child is ConfigBlock:
			options.append(child)
	return options

func clear() -> void:
	for option: ConfigBlock in get_options():
		option.queue_free()

func get_json() -> Dictionary:
	var options := {}
	var value_keys := {}
	var option_descs := {}
	for option: ConfigBlock in get_options():
		var option_json := option.get_json()
		var option_name: String = option_json.keys()[0]
		var desc = option_json._desc
		option_json.erase("_desc")
		if option_json:
			options.merge({option_name: option_json.values()[0][0]})
			value_keys.merge(option_json)
			if not (desc is String and desc == ""):
				option_descs.merge({option_name: desc})
	
	var json := {
		"options": options,
		"value_keys": value_keys
	}
	if option_descs:
		json.option_descs = option_descs
	return json

func preview_json() -> void:
	JSONPreview.open(get_json())

func save() -> void:
	if not Global.directory:
		MessageLog.log_error("No pack folder set.")
		return
	Global.write_json(Global.directory.path_join("config.json"), get_json())
	update_config()

func _process(_delta) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("save"):
		save()

func update_config() -> void:
	Global.config.clear()
	var value_keys: Dictionary = get_json().value_keys
	for key: String in value_keys.keys():
		Global.config.append(ConfigVariationCategory.create(key, value_keys.get(key)))
	Global.config_changed.emit()
