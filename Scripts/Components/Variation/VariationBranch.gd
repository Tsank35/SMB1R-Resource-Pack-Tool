class_name VariationBranch extends VariationComponent

const VARIATION_BLOCK := "res://Scenes/Components/Variation/VariationBlock.tscn"

var category: VariationCategory:
	set(value):
		category = value
		category_changed.emit()
var apply_config := false

@export var category_dropdown: OptionButton

signal children_changed
signal category_changed

func _ready() -> void:
	update_categories()
	Global.config_changed.connect(update_categories)

func add_variation(key := "", json := {}) -> void:
	var block: VariationBlock = Global.instantiate(VARIATION_BLOCK)
	block.variation_branch = self
	block.asset_type = variation_block.asset_type
	add_child(block)
	if key:
		block.set_variation_key(key)
	if json:
		block.apply_json(json)
	children_changed.emit()
	block.tree_exited.connect(children_changed.emit)

func update_categories() -> void:
	if Global.changing_directories:
		return
	category_dropdown.clear()
	var categories := Global.get_variation_categories()
	var found := false
	for c: VariationCategory in categories:	
		if c is ConfigVariationCategory:
			category_dropdown.add_item("Config: " + c.resource_name)
		else:
			category_dropdown.add_item(c.resource_name)
		category_dropdown.set_item_metadata(category_dropdown.item_count - 1, c)
		if category and not found:
			if category.resource_name == c.resource_name:
				category = c
				category_dropdown.select(category_dropdown.item_count - 1)
				found = true
	if not found:
		if category:
			MessageLog.log_error("Invalid category: " + category.resource_name, self)
		category_dropdown.select(0)
		category = categories[0]

func select_category(index: int) -> void:
	category = category_dropdown.get_item_metadata(index)

func add_all_variations() -> void:
	var skip := []
	for block: VariationBlock in get_variation_blocks():
		skip.append(block.variation)
	for i: int in category.variations.size():
		var current := category.variations[i]
		if current.is_custom:
			continue
		if skip.has(current):
			continue
		add_variation(current.key)

func get_variation_blocks() -> Array[VariationBlock]:
	var blocks: Array[VariationBlock] = []
	for child: Node in get_children():
		if child is VariationBlock:
			blocks.append(child)
	return blocks

func get_json(remove_redundant := true) -> Dictionary:
	var json := {}
	var variation_name := ""
	for block: VariationBlock in get_variation_blocks():
		var block_json := block.get_json(remove_redundant)
		json.merge(block_json)
		if block_json:
			variation_name = block.variation.resource_name
	if json.size() == 1 and remove_redundant:
		MessageLog.log_warning(variation_name + " is the only child of the branch, so only the contents were returned.", self)
		return json.values()[0]
	if category is ConfigVariationCategory:
		return {category.key: json}
	return json

func apply_json(json: Dictionary) -> void:
	var first_key = json.keys()[0]
	if first_key is not String:
		MessageLog.type_error(TYPE_STRING, typeof(first_key), self)
		return
	
	category = Global.get_category_from_key(first_key)
	if category is ConfigVariationCategory:
		json = json[first_key]
	
	if category:
		for i: int in category_dropdown.item_count:
			if category == category_dropdown.get_item_metadata(i):
				category_dropdown.select(i)
				break
	else:
		category = Global.get_variation_categories()[0]
		MessageLog.log_warning("Couldn't find category from key: " + first_key + ".", self)
	
	for key in json.keys():
		if key is String:
			add_variation(key, Global.get_value_of_type(json, key, TYPE_DICTIONARY, self))
		else:
			MessageLog.type_error(TYPE_STRING, typeof(key), self)
	apply_config = false
