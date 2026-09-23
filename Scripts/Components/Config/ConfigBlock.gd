class_name ConfigBlock extends DataBlock

const CONFIG_VALUE := "res://Scenes/Components/Config/ConfigValue.tscn"

var one_description := true: set = set_one_description

@export var name_input: LineEdit
@export var description_input: LineEdit
@export var one_description_checkbox: CheckBox
@export var value_container: VBoxContainer

signal one_description_changed

func add_value(value := "") -> void:
	var new_value: ConfigValue = Global.instantiate(CONFIG_VALUE)
	new_value.parent_block = self
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

func set_descriptions(value: Variant) -> void:
	if value is String:
		description_input.text = value
		one_description = true
	elif value is Array:
		var i := 0
		for config_value in get_values():
			if i < value.size():
				config_value.set_description(value[i])
				i += 1
			else:
				break
		one_description = false
	one_description_checkbox.set_pressed_no_signal(one_description)

func set_one_description(value: bool) -> void:
	one_description = value
	description_input.visible = one_description
	one_description_changed.emit()

func get_json(_remove_redundant := true) -> Dictionary:
	var values := []
	var description = null
	for value: ConfigValue in get_values():
		values.append(value.get_value())
		if not one_description:
			if description == null:
				description = []
			description.append(value.get_description())
	
	if not values:
		return {}
	
	if one_description:
		description = description_input.text
	
	return {
		name_input.text: values,
		"_desc": description
	}

func apply_json(json: Dictionary) -> void:
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
	
	if json.has("_desc"):
		set_descriptions(json._desc)

func copy_json() -> Dictionary:
	return get_json(false)
