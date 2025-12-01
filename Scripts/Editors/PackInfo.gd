extends VBoxContainer

@export_group("Nodes")
@export var directory_display: LineEdit
@export var name_input: LineEdit
@export var author_input: LineEdit
@export var description_input: TextEdit
@export var version_input: LineEdit
@export var version_label: Label
@export var file_dialog: FileDialog

func _ready() -> void:
	version_label.text = "v" + ProjectSettings.get_setting("application/config/version") + "\n" + version_label.text
	var data_dir := OS.get_data_dir()
	var res_pack_dir := data_dir.path_join("SMB1R/resource_packs")
	if DirAccess.dir_exists_absolute(res_pack_dir):
		file_dialog.current_dir = res_pack_dir
	else:
		file_dialog.current_dir = data_dir

func set_pack_dir(dir: String) -> void:
	Global.directory = dir
	directory_display.text = dir
	var json := Global.read_json(dir.path_join("pack_info.json"))
	if json.has("name"):
		name_input.text = Global.get_value_of_type(json, "name", TYPE_STRING)
	else:
		name_input.text = "New Pack"
	if json.has("author"):
		author_input.text = Global.get_value_of_type(json, "author", TYPE_STRING)
	else:
		author_input.text = "Me, until you change it"
	if json.has("description"):
		description_input.text = Global.get_value_of_type(json, "description", TYPE_STRING)
	else:
		description_input.text = "Template, give me a description!"
	if json.has("version"):
		version_input.text = Global.get_value_of_type(json, "version", TYPE_STRING)
	else:
		version_input.text = "1.0"

func save() -> void:
	if not Global.directory:
		MessageLog.log_error("No pack folder set.")
		return
	var json := {
		"author": author_input.text,
		"description": description_input.text,
		"name": name_input.text,
		"version": version_input.text
	}
	Global.write_json(Global.directory.path_join("pack_info.json"), json)
	MessageLog.log_message("Saved pack_info.json.")

func _process(_delta) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("save"):
		save()
