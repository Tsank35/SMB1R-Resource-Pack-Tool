class_name NewFileButton extends TextureButton

enum BaseDirectory {
	SPRITE,
	MUSIC
}

@export var formats := PackedStringArray()
@export var base_directory := BaseDirectory.SPRITE

signal file_created(path: String)

func on_pressed() -> void:
	var dir := ""
	match base_directory:
		BaseDirectory.SPRITE:
			dir = Global.directory.path_join("Sprites")
		BaseDirectory.MUSIC:
			dir = Global.directory.path_join("Audio/BGM")
	
	var filter := ""
	var first := true
	for format: String in formats:
		if first:
			first = false
		else:
			filter += ", "
		filter += "*." + format
	NewFileDialog.filters = [filter]
	
	NewFileDialog.current_dir = dir
	NewFileDialog.file_selected.connect(create_file)
	NewFileDialog.canceled.connect(disconnect_signals)
	NewFileDialog.close_requested.connect(disconnect_signals)
	NewFileDialog.popup_centered()

func create_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.close()
	file_created.emit(path)
	disconnect_signals()

func disconnect_signals() -> void:
	var connections := {
		NewFileDialog.file_selected: create_file,
		NewFileDialog.canceled: disconnect_signals,
		NewFileDialog.close_requested: disconnect_signals
	}
	for s: Signal in connections.keys():
		var callable: Callable = connections.get(s)
		if s.is_connected(callable):
			s.disconnect(callable)
