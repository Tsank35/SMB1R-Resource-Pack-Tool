extends ColorRect

var file := "": set = set_file
var formats := PackedStringArray()
var base_directory := ""
var restrict_to_base := false
var aseprite := false
var connected_callable := Callable()

@export_group("Nodes")
@export var selected_file_label: Label
@export var format_label: Label
@export var warning: Label
@export var import_button: Button
@export var copy_button: Button
@export var file_dialog: FileDialog
@export var aseprite_config: ConfirmationDialog
@export var frame_duration_input: SpinBox
@export var separate_tags_buttton: CheckBox

signal file_selected(path: String, data: Dictionary)

func _ready() -> void:
	get_parent().move_child.call_deferred(self, get_parent().get_child_count() - 1)

func open(connect_signal: Callable) -> void:
	connected_callable = connect_signal
	file_selected.connect(connected_callable)
	format_label.text = "Valid formats: "
	var first := true
	for format: String in formats:
		if first:
			first = false
		else:
			format_label.text += ", "
		format_label.text += format
	get_window().files_dropped.connect(drop_files)
	selected_file_label.hide()
	warning.hide()
	import_button.disabled = true
	copy_button.disabled = true
	show()

func close() -> void:
	get_window().files_dropped.disconnect(drop_files)
	hide()
	if connected_callable:
		file_selected.disconnect(connected_callable)
		connected_callable = Callable()

func set_file(value: String) -> void:
	file = value
	if file:
		selected_file_label.text = "Selected: " + file.get_file()
		selected_file_label.show()
		warning.visible = (not file.begins_with(base_directory + "/") and restrict_to_base)
		import_button.disabled = warning.visible
		copy_button.disabled = base_directory.is_empty() or file == base_directory.path_join(file.get_file())
	else:
		selected_file_label.hide()
		warning.hide()
		import_button.disabled = true
		copy_button.disabled = true

func select_file(path: String) -> void:
	file = path.replace("\n".c_escape().substr(0, 1), "/")

func drop_files(files: PackedStringArray) -> void:
	if formats.has(files[0].get_extension()):
		select_file(files[0])
	else:
		MessageLog.log_error("Invalid file type.")

func browse() -> void:
	if base_directory:
		file_dialog.current_dir = base_directory
	var filter := ""
	var first := true
	for format: String in formats:
		if first:
			first = false
		else:
			filter += ", "
		filter += "*." + format
	file_dialog.filters = [filter]
	file_dialog.popup_centered()

func import() -> void:
	if aseprite:
		aseprite_config.popup_centered()
	else:
		file_selected.emit(file, {})
		close()

func copy_to_folder() -> void:
	var copy_path := base_directory.path_join(file.get_file())
	var buffer := FileAccess.get_file_as_bytes(file)
	var copy_file := FileAccess.open(copy_path, FileAccess.WRITE)
	copy_file.store_buffer(buffer)
	copy_file.close()
	file = copy_path

func confirm_aseprite_import() -> void:
	file_selected.emit(file, {
		"speed": frame_duration_input.value,
		"separate_tags": separate_tags_buttton.button_pressed
	})
	close()
