extends Node

const VARIATION_CATEGORIES := [
	"res://Resources/Variations/ThemeVariations.tres",
	"res://Resources/Variations/TimeVariations.tres",
	"res://Resources/Variations/CampaignVariations.tres",
	"res://Resources/Variations/WorldVariations.tres",
	"res://Resources/Variations/LevelVariations.tres",
	"res://Resources/Variations/RoomVariations.tres",
	"res://Resources/Variations/GameModeVariations.tres",
	"res://Resources/Variations/CharacterVariations.tres",
	"res://Resources/Variations/RaceBooVariations.tres"
]

enum AssetType {
	SPRITE,
	AUDIO
}

var directory := "":
	set(value):
		directory = value
		asset_path = ""
		changing_directories = true
		directory_changed.emit()
		changing_directories = false
var config: Array[ConfigVariationCategory] = []
var asset_path := ""
var asset_type := AssetType.SPRITE
var reference_source: VariationComponent:
	set(value):
		reference_source = value
		if emit_reference_signal:
			reference_changed.emit()
	get:
		if not is_instance_valid(reference_source) or reference_source.is_queued_for_deletion():
			emit_reference_signal = false
			reference_source = get_tree().get_first_node_in_group("Sources")
			emit_reference_signal = true
		return reference_source
var clipboard := {}
var clipboard_type := DataBlock.DataType.VARIATION

var changing_directories := false
var emit_reference_signal := true

signal directory_changed
signal config_changed
signal reference_changed
@warning_ignore("unused_signal")
signal sources_changed

func remove_directory(path: String, dir: String) -> String:
	if path.begins_with(dir + "/"):
		return path.substr((dir + "/").length())
	return path

func write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(Stringifier.stringify(data))
	file.close()

func read_json(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		file.close()
		if json is Dictionary:
			return json
		else:
			MessageLog.log_error("Error parsing " + path.get_file() + ".")
	return {}

func instantiate(path: String) -> Node:
	if ResourceLoader.exists(path, "PackedScene"):
		return load(path).instantiate()
	return null

func get_value_of_type(json: Dictionary, key: String, type: Variant.Type, error_source = null, array_type := TYPE_NIL) -> Variant:
	if json.has(key):
		var value = json.get(key)
		if matches_type(value, type):
			var valid := true
			if value is Array:
				for i in value:
					if not matches_type(i, array_type):
						valid = false
						MessageLog.type_error(array_type, typeof(i), error_source)
						break
			if valid:
				return value
		else:
			MessageLog.type_error(type, typeof(value), error_source)
	return type_convert("", type)

func matches_type(value: Variant, type: Variant.Type) -> bool:
	if typeof(value) == type:
		return true
	const numbers := [TYPE_INT, TYPE_FLOAT]
	if numbers.has(typeof(value)) and numbers.has(type):
		return true
	return false

func type_name(type: Variant.Type) -> String:
	match type:
		TYPE_BOOL:
			return "boolean"
		TYPE_INT, TYPE_FLOAT:
			return "number"
		TYPE_STRING:
			return "text"
	return type_string(type)

func get_variation_categories() -> Array[VariationCategory]:
	var categories: Array[VariationCategory] = []
	for path: String in VARIATION_CATEGORIES:
		categories.append(load(path))
	categories.append_array(config)
	return categories
