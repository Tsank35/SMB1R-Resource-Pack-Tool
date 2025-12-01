class_name VariationBlock extends DataBlock

const DEFAULT_ICON := "res://Assets/Icons/DefaultVariation.png"

enum ComponentType {
	VARIATION_BRANCH,
	SOURCE,
	LINK,
	RANDOM
}
enum AssetType {
	SPRITE,
	MUSIC,
	SOUND
}

@export var is_root := false
@export var asset_type := AssetType.SPRITE

var variation: Variation: set = set_variation
var component: VariationComponent
var variation_branch: VariationBranch

@export_group("Nodes")
@export var icon: TextureRect
@export var variation_dropdown: OptionButton
@export var custom_variation_input: LineEdit
@export var component_menu: ItemList

func _ready() -> void:
	super()
	if variation_branch:
		update_variations()
		variation_branch.category_changed.connect(update_variations)

func set_variation(value: Variation) -> void:
	variation = value
	icon.texture = variation.icon
	variation_dropdown.tooltip_text = get_variation_key()
	custom_variation_input.visible = variation.is_custom
	color_1 = variation.color_1
	color_2 = variation.color_2
	color_3 = variation.color_3
	if variation_branch:
		variation_branch.children_changed.emit()

func set_variation_key(key: String) -> void:
	for i: int in variation_dropdown.item_count:
		var current: Variation = variation_dropdown.get_item_metadata(i)
		if current.is_custom:
			if not current.key:
				select_variation(i)
				custom_variation_input.text = key
				return
			elif key.begins_with(current.key):
				select_variation(i)
				custom_variation_input.text = key.substr(current.key.length())
				return
		elif key == current.key:
			select_variation(i)
			return
	MessageLog.log_error("Invalid key: " +  key + ".", self)

func select_variation(index: int) -> void:
	variation = variation_dropdown.get_item_metadata(index)
	if variation_dropdown.selected != index:
		variation_dropdown.select(index)

func update_variations() -> void:
	variation_dropdown.clear()
	var found := false
	for v: Variation in get_category().variations:
		if variation_dropdown.item_count == 0 and get_category() is not ConfigVariationCategory:
			variation_dropdown.add_icon_item(load(DEFAULT_ICON), v.resource_name)
		else:
			variation_dropdown.add_item(v.resource_name)
		variation_dropdown.set_item_metadata(variation_dropdown.item_count - 1, v)
		if variation and not found:
			if variation.key == v.key:
				select_variation(variation_dropdown.item_count - 1)
				found = true
	if not found:
		if variation:
			MessageLog.log_error("Invalid variation: " + variation.resource_name, self)
		select_variation(0)

func add_component(index: int, json := {}) -> void:
	component = get_component(index, asset_type)
	component.variation_block = self
	content_container.add_child(component)
	if json:
		component.apply_json(json)
	component.tree_exited.connect(clear_component)
	
	component_menu.hide()
	component_menu.deselect(index)

static func get_component(component_type: ComponentType, asset := AssetType.SPRITE) -> VariationComponent:
	var path := ""
	match component_type:
		ComponentType.VARIATION_BRANCH:
			path = "res://Scenes/Components/Variation/VariationBranch.tscn"
		ComponentType.SOURCE:
			match asset:
				AssetType.SPRITE:
					path = "res://Scenes/Components/Sprite/SpriteSource.tscn"
				AssetType.MUSIC:
					path = "res://Scenes/Components/Music/MusicSource.tscn"
		ComponentType.LINK:
			path = "res://Scenes/Components/Variation/VariationLink.tscn"
		ComponentType.RANDOM:
			path = "res://Scenes/Components/Variation/RandomBranch.tscn"
	return Global.instantiate(path)

func clear_component() -> void:
	if is_instance_valid(component):
		component.tree_exited.disconnect(clear_component)
		component.queue_free()
	component = null
	component_menu.show()

func custom_variation_changed() -> void:
	variation_dropdown.tooltip_text = get_variation_key()
	variation_branch.children_changed.emit()
	if component and component.is_in_group("Sources"):
		Global.sources_changed.emit()

func get_block_path() -> String:
	if is_root:
		return "root"
	var path := ""
	var current := self
	while not current.is_root:
		if path:
			path = current.get_variation_key().path_join(path)
		else:
			path = current.get_variation_key()
		current = current.variation_branch.variation_block
	return path

func get_display_name() -> String:
	if variation.is_custom:
		if variation.key:
			return variation.resource_name + ": " + custom_variation_input.text
		return custom_variation_input.text
	return variation.resource_name

func get_variation_key() -> String:
	if variation.is_custom:
		return variation.key + custom_variation_input.text
	return variation.key

func get_category() -> VariationCategory:
	if variation_branch:
		return variation_branch.category
	return null

func get_json(remove_redundant := true) -> Dictionary:
	var json := {}
	if component:
		json = component.get_json(remove_redundant)
		if is_root:
			return {"variations": json}
	if not json and remove_redundant:
		MessageLog.log_warning("Skipped empty variation block.", self)
		return {}
	return {get_variation_key(): json}

func apply_json(json: Dictionary) -> void:
	clear_component()
	if not json:
		return
	if json.has("source"):
		add_component(ComponentType.SOURCE, json)
	elif json.has("link"):
		add_component(ComponentType.LINK, json)
	elif json.has("choices"):
		add_component(ComponentType.RANDOM, json)
	else:
		add_component(ComponentType.VARIATION_BRANCH, json)

func copy() -> void:
	if component is SpriteSource:
		data_type = DataType.SOURCE
	else:
		data_type = DataType.VARIATION
	super()

func paste() -> void:
	if [DataType.VARIATION, DataType.SOURCE].has(Global.clipboard_type):
		data_type = Global.clipboard_type
	super()
