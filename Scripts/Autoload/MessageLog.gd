extends VBoxContainer

const MESSAGE := "res://Scenes/Components/LogMessage.tscn"

func log_message(text: String, source: Variant = null, color := Color.WHITE) -> void:
	var message: Label = Global.instantiate(MESSAGE)
	if source == null:
		message.text = text
	elif source is VariationBlock:
		message.text = source.get_block_path() + ": " + text
	elif source is VariationComponent:
		message.text = source.get_component_path() + ": " + text
	elif source is AnimationCollection:
		var path := "animations"
		if source.source:
			path = source.source.get_component_path() + path
		message.text = path + ": " + text
	elif source is AnimationBlock:
		message.text = "animations/" + source.get_animation_name() + ": " + text
	elif source is PropertyBlock:
		var path := "properties"
		if source.source:
			path = source.source.get_component_path() + path
		message.text = path + ": " + text
	elif source is SpriteProperty:
		message.text = "properties/" + source.get_property_name() + ": " + text
	message.add_theme_color_override("font_color", color)
	add_child(message)

func log_error(text: String, source: Variant = null) -> void:
	log_message(text, source, Color.RED)

func log_warning(text: String, source: Variant = null) -> void:
	log_message(text, source, Color.YELLOW)

func type_error(expected: Variant.Type, found: Variant.Type, source: Variant = null) -> void:
	log_error("Expected " + Global.type_name(expected) + ", found " + Global.type_name(found) + " instead.", source)
