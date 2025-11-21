class_name ConfigValue extends HBoxContainer

@export var input: LineEdit

func set_value(value: String) -> void:
	input.text = value

func get_value() -> String:
	return input.text
