class_name SpriteSource extends VariationComponent

var path := "": set = set_path
var texture: Texture2D:
	set(value):
		texture = value
		rect.texture = texture
		rect.set_enabled(texture != null)
		if texture:
			rect.set_boundaries(texture.get_size())
		update_image()
var use_full_image := true:
	set(value):
		use_full_image = value
		rect.visible = not use_full_image
		update_image()
var random_choice: RandomChoice

@export_group("Nodes")
@export var source_label: Label
@export var image_button: ImageButton
@export var full_image_checkbox: CheckBox
@export var rect: SpriteRect
@export var property_block: PropertyBlock
@export var animation_block: DataBlock
@export var animation_overrides: AnimationCollection
@export var new_animations: AnimationCollection

func _ready() -> void:
	if animation_overrides.is_empty() and new_animations.is_empty():
		animation_block.set_collapsed(true)
	if random_choice:
		$HBox/DeleteButton.queue_free()
	rect.move_child(rect.get_node("Label"), 0)

func set_path(value: String) -> void:
	path = value
	source_label.text = "Source: " + path
	if path:
		var full_path := Global.asset_path.get_base_dir().path_join(path)
		if FileAccess.file_exists(full_path):
			texture = ImageTexture.create_from_image(Image.load_from_file(full_path))
		else:
			texture = null
			MessageLog.log_error("Image not found: " + path, self)
	else:
		texture = null

func update_image() -> void:
	image_button.texture = texture
	image_button.use_rect = not use_full_image
	if not use_full_image:
		image_button.rect = rect.rect
	if Global.reference_source == self:
		Global.reference_changed.emit()

func get_cropped_texture() -> Texture2D:
	if not texture:
		return null
	if use_full_image:
		return texture
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = rect.rect
	return atlas

func select_file(file_path: String) -> void:
	path = Global.remove_directory(file_path, Global.asset_path.get_base_dir())

func set_use_full_image(toggled_on: bool) -> void:
	use_full_image = toggled_on

func is_rect_full() -> bool:
	if not texture:
		return false
	return rect.rect == Rect2(Vector2.ZERO, texture.get_size())

func get_component_path() -> String:
	if random_choice:
		if variation_block.is_root:
			return random_choice.get_custom_label()
		return super().path_join(random_choice.get_custom_label())
	return super()

func get_json(remove_redundant := true) -> Dictionary:
	if not path and remove_redundant:
		MessageLog.log_warning("Skipped empty source.", self)
		return {}
	var json := {"source": path}
	if not use_full_image:
		if is_rect_full() and remove_redundant:
			MessageLog.log_warning("Skipped rect, for it stretches over the entire image.", self)
		else:
			json.merge({"rect": rect.get_rect_array()})
	if random_choice and not remove_redundant:
		json.merge({"label": random_choice.get_custom_label()})
	json.merge(property_block.get_json(remove_redundant))
	json.merge(animation_overrides.get_json(remove_redundant))
	json.merge(new_animations.get_json(remove_redundant))
	return json

func apply_json(json: Dictionary) -> void:
	if json.has("source"):
		path = Global.get_value_of_type(json, "source", TYPE_STRING, self)
	else:
		MessageLog.log_warning("No source given.", self)
	
	if json.has("rect"):
		var rect_array: Array = Global.get_value_of_type(json, "rect", TYPE_ARRAY, self, TYPE_INT)
		if rect_array:
			rect.set_rect_from_array(rect_array)
		use_full_image = false
		full_image_checkbox.set_pressed_no_signal(false)
	
	property_block.apply_json(Global.get_value_of_type(json, "properties", TYPE_DICTIONARY, self))
	animation_overrides.apply_json(Global.get_value_of_type(json, "animation_overrides", TYPE_DICTIONARY, self))
	new_animations.apply_json(Global.get_value_of_type(json, "animations", TYPE_DICTIONARY, self))
	animation_block.set_collapsed(not json.has("animation_overrides") and not json.has("animations"))
