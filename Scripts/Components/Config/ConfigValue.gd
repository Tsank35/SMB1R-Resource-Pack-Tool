class_name ConfigValue extends HBoxContainer

var parent_block: ConfigBlock

@export var value_input: LineEdit
@export var description_input: LineEdit
@export var spacer: Control

func _ready() -> void:
	parent_block.one_description_changed.connect(update)
	update()

func update() -> void:
	description_input.visible = not parent_block.one_description
	spacer.visible = parent_block.one_description

func set_value(value: String) -> void:
	value_input.text = value

func set_description(value: String) -> void:
	description_input.text = value

func get_value() -> String:
	return value_input.text

func get_description() -> String:
	return description_input.text
