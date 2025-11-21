class_name FileButton extends TextureButton

enum PrependBaseDir {
	NONE,
	PACK,
	ASSET
}

@export var formats := PackedStringArray()
@export var prepend_base_dir := PrependBaseDir.NONE
@export var base_directory := ""
@export var restrict_to_base_directory := false
@export var aseprite := false

signal file_selected(path: String)
signal aseprite_selected(path: String, speed: float, seperate_tags: bool)

func on_pressed() -> void:
	var dir := ""
	match prepend_base_dir:
		PrependBaseDir.PACK:
			dir = Global.directory
		PrependBaseDir.ASSET:
			dir = Global.asset_path.get_base_dir()
	if base_directory:
		dir = dir.path_join(base_directory)
	FileImport.formats = formats
	FileImport.base_directory = dir
	FileImport.restrict_to_base = restrict_to_base_directory
	FileImport.aseprite = aseprite
	FileImport.open(select_file)

func select_file(path: String, data := {}) -> void:
	if aseprite:
		aseprite_selected.emit(path, data.speed, data.separate_tags)
	else:
		file_selected.emit(path)
