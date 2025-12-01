class_name VariationComponent extends BoxContainer

var variation_block: VariationBlock

func get_component_path() -> String:
	return variation_block.get_block_path()

@warning_ignore("unused_parameter")
func get_json(remove_redundant := true) -> Dictionary:
	return {}

@warning_ignore("unused_parameter")
func apply_json(json: Dictionary) -> void:
	pass
