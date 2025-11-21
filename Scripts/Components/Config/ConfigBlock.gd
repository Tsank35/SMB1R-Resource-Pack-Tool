class_name ConfigBlock extends DataBlock

const CONFIG_VALUE := "res://Scenes/Components/Config/ConfigValue.tscn"

@export var name_input: LineEdit
@export var value_container: VBoxContainer

func add_value(value := "") -> void:
	var new_value: ConfigValue = Global.instantiate(CONFIG_VALUE)
	value_container.add_child(new_value)
	if value:
		new_value.set_value(value)

func get_values() -> Array[ConfigValue]:
	var values: Array[ConfigValue] = []
	for child: Node in value_container.get_children():
		if child is ConfigValue:
			values.append(child)
	return values

func clear() -> void:
	for value: ConfigValue in get_values():
		queue_free()

func set_option_name(value: String) -> void:
	name_input.text = value

func get_json(_remove_redundant := true) -> Dictionary:
	var values := []
	for value: ConfigValue in get_values():
		values.append(value.get_value())
	if not values:
		return {}
	return {name_input.text: values}

func apply_json(json: Dictionary, _apply_exact := false) -> void:
	clear()
	var values = json.values()[0]
	if values is Array:
		for value in values:
			if value is String:
				add_value(value)
			else:
				MessageLog.type_error(TYPE_STRING, typeof(value))
	else:
		MessageLog.type_error(TYPE_ARRAY, typeof(values))

func copy_json() -> Dictionary:
	return get_json(false)
