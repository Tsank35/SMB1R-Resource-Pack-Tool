@tool
class_name CollapseAllButton extends TextureButton

const TEXTURES := [
	"res://Assets/Buttons/UncollapseAll.png",
	"res://Assets/Buttons/CollapseAll.png"
]
const TOOLTIPS := [
	"Uncollapse All",
	"Collapse All"
]

@export var collapse_all := true:
	set(value):
		collapse_all = value
		texture_normal = load(TEXTURES[int(collapse_all)])
		tooltip_text = TOOLTIPS[int(collapse_all)]
@export var parent: Node

func on_pressed() -> void:
	for child: Node in parent.get_children():
		if child is DataBlock:
			child.set_collapsed(collapse_all)
