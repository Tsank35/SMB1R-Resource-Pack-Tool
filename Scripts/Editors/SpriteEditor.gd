extends Control

var reference_update_queued := false

@export var path_display: LineEdit
@export var reference_dropdown: OptionButton
@export var property_block: PropertyBlock
@export var animation_collection: AnimationCollection
@export var root_variation: VariationBlock
@export var file_dialog: FileDialog

func _ready() -> void:
	Global.directory_changed.connect(directory_changed)
	Global.sources_changed.connect(queue_reference_update)

func directory_changed() -> void:
	path_display.text = Global.remove_directory(Global.sprite_path,  Global.directory.path_join("Sprites"))

func select_file(path: String, apply := true) -> void:
	Global.sprite_path = path
	path_display.text = Global.remove_directory(path,  Global.directory.path_join("Sprites"))
	if apply:
		var json := Global.read_json(path)
		if json.has("variations"):
			root_variation.apply_json(Global.get_value_of_type(json, "variations", TYPE_DICTIONARY))
		else:
			root_variation.clear_component()
		if json.has("properties"):
			property_block.apply_json(Global.get_value_of_type(json, "properties", TYPE_DICTIONARY))
		else:
			property_block.clear()
		if json.has("animations"):
			animation_collection.apply_json(Global.get_value_of_type(json, "animations", TYPE_DICTIONARY))
		else:
			animation_collection.clear()

func preview_json() -> void:
	JSONPreview.open(get_json())

func save() -> void:
	if not Global.sprite_path:
		MessageLog.log_error("No file set. Import a file or a create a new one.")
		return
	Global.write_json(Global.sprite_path, get_json())
	MessageLog.log_message("Saved " + Global.sprite_path.get_file() + ".")

func _process(_delta) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("save"):
		save()

func get_json() -> Dictionary:
	var json := {}
	json.merge(property_block.get_json())
	json.merge(animation_collection.get_json())
	json.merge(root_variation.get_json())
	return json

func update_references() -> void:
	reference_update_queued = false
	var selected = null
	if reference_dropdown.selected > -1:
		selected = reference_dropdown.get_item_metadata(reference_dropdown.selected)
	
	reference_dropdown.clear()
	for node: Node in get_tree().get_nodes_in_group("Sources"):
		if node is SpriteSource:
			reference_dropdown.add_item(node.get_component_path())
			reference_dropdown.set_item_metadata(reference_dropdown.item_count - 1, node)
	
	if selected:
		for i: int in reference_dropdown.item_count:
			if reference_dropdown.get_item_metadata(i) == selected:
				reference_dropdown.select(i)
				return
	
	if reference_dropdown.item_count > 0:
		reference_dropdown.select(0)
		reference_dropdown.item_selected.emit(0)

func queue_reference_update() -> void:
	if reference_update_queued:
		return
	reference_update_queued = true
	update_references.call_deferred()

func select_reference(index: int) -> void:
	if index > -1:
		Global.reference_source = reference_dropdown.get_item_metadata(index)

func new_file() -> void:
	file_dialog.current_dir = Global.directory.path_join("Sprites")
	file_dialog.popup_centered()

func create_file(path: String) -> void:
	Global.write_json(path, {})
	select_file(path, false)
