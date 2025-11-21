class_name LinearOptionButton extends OptionButton

func _ready() -> void:
	get_popup().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
