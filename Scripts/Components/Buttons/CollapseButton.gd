@tool
class_name CollapseButton extends TextureButton

@export var nodes_to_hide: Array[Control] = []

func on_toggled(toggled_on: bool) -> void:
	for node: Control in nodes_to_hide:
		node.visible = not toggled_on
