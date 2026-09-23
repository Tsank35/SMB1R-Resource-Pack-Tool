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
		if child is ConfigValue and not child.is_queued_for_deletion():
			values.append(child)
	return values

func clear() -> void:
	for value: ConfigValue in get_values():
		value.queue_free()

func set_option_name(value: String) -> void:
	name_input.text = value

func set_descriptions(descs: Variant) -> void:
	if descs is String:
		description_input.text = descs
		one_description = true
	elif descs is Array:
		description_input.clear()
		var i := 0
		for value in get_values():
			if i < descs.size():
				value.set_description(descs[i])
				i += 1
			else:
				break
		one_description = false
	one_description_checkbox.set_pressed_no_signal(one_description)

func set_one_description(value: bool) -> void:
	one_description = value
	description_input.visible = one_description
	one_description_changed.emit()

func get_description() -> Variant:
	if one_description:
		return description_input.text
	else:
		var descriptions := []
		for value: ConfigValue in get_values():
			descriptions.append(value.get_description())
		return descriptions

func get_json(_remove_redundant := true) -> Dictionary:
	var values := []
	for value: ConfigValue in get_values():
		values.append(value.get_value())
	if not values:
		return {}
	
	return {
		name_input.text: values,
		"_desc": get_description()
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
