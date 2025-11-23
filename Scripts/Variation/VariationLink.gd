class_name VariationLink extends VariationComponent

@export var dropdown: OptionButton

func _ready() -> void:
	update()
	variation_block.variation_branch.children_changed.connect(update)

func update() -> void:
	var selected: VariationBlock = null
	if dropdown.selected > -1:
		selected = dropdown.get_item_metadata(dropdown.selected)
	dropdown.clear()
	for block: VariationBlock in variation_block.variation_branch.get_variation_blocks():
		if block == variation_block:
			continue
		dropdown.add_item(block.get_display_name())
		dropdown.set_item_metadata(dropdown.item_count - 1, block)
	if selected:
		select_block(selected)

func select_block(block: VariationBlock) -> void:
	for i: int in dropdown.item_count:
		if dropdown.get_item_metadata(i) == block:
			dropdown.select(i)
			return
	dropdown.select(0)
	MessageLog.log_error("Invalid link: " + block.get_variation_key() + ".", self)

func select_key(key: String) -> void:
	for i: int in dropdown.item_count:
		var block = dropdown.get_item_metadata(i)
		if block is VariationBlock:
			if block.get_variation_key() == key:
				dropdown.select(i)
				return
	dropdown.select(0)
	MessageLog.log_error("Invalid link: " + key + ".", self)

func get_json(remove_redundant := true) -> Dictionary:
	var block: VariationBlock = dropdown.get_item_metadata(dropdown.selected)
	if block:
		if block.variation == block.get_category().variations[0] and remove_redundant:
			MessageLog.log_warning("Skipped link, for it references the default variation.", self)
			return {}
		return {"link": block.get_variation_key()}
	return {}

func apply_json(json: Dictionary) -> void:
	select_key.call_deferred(Global.get_value_of_type(json, "link", TYPE_STRING, self))
