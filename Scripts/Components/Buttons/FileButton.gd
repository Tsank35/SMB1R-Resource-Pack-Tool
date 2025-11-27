class_name FileButton extends TextureButton

enum PrependBaseDir {
	NONE,
	PACK,
	SPRITE
}

@export var formats := PackedStringArray()
@export var prepend_base_dir := PrependBaseDir.NONE
@export var base_directory := ""
@export var restrict_to_base_directory := false
@export var aseprite := false

signal file_selected(path: String)
signal aseprite_imported(data: Dictionary)

func on_pressed() -> void:
	var dir := ""
	match prepend_base_dir:
		PrependBaseDir.PACK:
			dir = Global.directory
		PrependBaseDir.SPRITE:
			dir = Global.sprite_path.get_base_dir()
	if base_directory:
		dir = dir.path_join(base_directory)
	FileImport.formats = formats
	FileImport.base_directory = dir
	FileImport.restrict_to_base = restrict_to_base_directory
	FileImport.aseprite = aseprite
	if aseprite:
		FileImport.open(import_aseprite)
	else:
		FileImport.open(select_file)

func select_file(path: String) -> void:
	file_selected.emit(path)

func import_aseprite(data: Dictionary) -> void:
	aseprite_imported.emit(data)
