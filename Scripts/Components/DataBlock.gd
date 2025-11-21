class_name DataBlock extends PanelContainer

enum DataType {
	VARIATION,
	SOURCE,
	PROPERTY,
	ANIMATION,
	ANIMATION_COLLECTION,
	CONFIG
}

@export var data_type := DataType.VARIATION
@export var color_1 := Color.WHITE:
	set(value):
		color_1 = value
		if material is ShaderMaterial:
			material.set_shader_parameter("color1", color_1)
@export var color_2 := Color(0.5, 0.5, 0.5):
	set(value):
		color_2 = value
		if material is ShaderMaterial:
			material.set_shader_parameter("color2", color_2)
@export var color_3 := Color8(31, 31, 31):
	set(value):
		color_3 = value
		if material is ShaderMaterial:
			material.set_shader_parameter("color3", color_3)

@export_group("Nodes")
@export var collapse_button: CollapseButton
@export var content_container: PanelContainer

func _ready() -> void:
	material = material.duplicate()
	content_container.material = material
	if material is ShaderMaterial:
		material.set_shader_parameter("color1", color_1)
		material.set_shader_parameter("color2", color_2)
		material.set_shader_parameter("color3", color_3)

func set_collapsed(collapsed: bool) -> void:
	collapse_button.button_pressed = collapsed

func copy() -> void:
	var json := copy_json()
	if json:
		Global.clipboard = json
		Global.clipboard_type = data_type
		MessageLog.log_message("Copied data.")
	else:
		MessageLog.log_error("No data to copy.")

func paste() -> void:
	if Global.clipboard:
		if Global.clipboard_type == data_type:
			apply_json(Global.clipboard, true)
			MessageLog.log_message("Pasted data.")
		else:
			MessageLog.log_error("Invalid data.")
	else:
		MessageLog.log_error("Clipboard is empty.")

func copy_json() -> Dictionary:
	var json := get_json(false)
	if json:
		return json.values()[0]
	return {}

@warning_ignore("unused_parameter")
func get_json(remove_redundant := true) -> Dictionary:
	return {}

@warning_ignore("unused_parameter")
func apply_json(json: Dictionary, apply_exact := false) -> void:
	pass
