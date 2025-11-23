class_name VariationComponent extends BoxContainer

var variation_block: VariationBlock

func _enter_tree() -> void:
	if is_in_group("Sources"):
		Global.sources_changed.emit()

func _exit_tree() -> void:
	if is_in_group("Sources"):
		remove_from_group("Sources")
		if Global.reference_source == self:
			Global.reference_source = null
		Global.sources_changed.emit()

func get_component_path() -> String:
	return variation_block.get_block_path()

@warning_ignore("unused_parameter")
func get_json(remove_redundant := true) -> Dictionary:
	return {}

@warning_ignore("unused_parameter")
func apply_json(json: Dictionary) -> void:
	pass
