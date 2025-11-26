class_name SpriteProperty extends HBoxContainer

enum Type {
	BOOLEAN,
	NUMBER,
	TEXT,
	VECTOR
}

var type := Type.BOOLEAN:
	set(value):
		get_input_component().hide()
		type = value
		get_input_component().show()

@export_group("Nodes")
@export var name_input: LineEdit
@export var boolean_input: CheckBox
@export var number_input: SpinBox
@export var text_input: LineEdit
@export var vector_container: BoxContainer
@export var vector_input: Array[SpinBox] = []
@export var type_dropdown: OptionButton

func select_type(index: int) -> void:
	@warning_ignore("int_as_enum_without_cast")
	type = index

func get_input_component() -> Control:
	match type:
		Type.BOOLEAN:
			return boolean_input
		Type.NUMBER:
			return number_input
		Type.TEXT:
			return text_input
		Type.VECTOR:
			return vector_container
	return null

func get_property_name() -> String:
	return name_input.text

func get_json() -> Dictionary:
	var value: Variant
	match type:
		Type.BOOLEAN:
			value = boolean_input.button_pressed
		Type.NUMBER:
			value = number_input.value
		Type.TEXT:
			value = text_input.text
		Type.VECTOR:
			value = [vector_input[0].value, vector_input[1].value]
	return {get_property_name(): value}

func apply_json(json: Dictionary) -> void:
	name_input.text = json.keys()[0]
	var value = json.values()[0]
	if value is bool:
		type = Type.BOOLEAN
		boolean_input.button_pressed = value
	elif value is int or value is float:
		type = Type.NUMBER
		number_input.value = value
	elif value is String:
		type = Type.TEXT
		text_input.text = value
	elif value is Array and value.size() == 2:
		type = Type.VECTOR
		vector_input[0].value = value[0]
		vector_input[1].value = value[1]
	else:
		MessageLog.log_error(Global.type_name(typeof(value)).capitalize() + " property values not supported.", self)
	type_dropdown.select(type)
