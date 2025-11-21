@tool
extends TextureButton

const TEXTURES := [
	"res://Assets/Buttons/Up.png",
	"res://Assets/Buttons/Down.png"
]
const TOOLTIPS := [
	"Move Up",
	"Move Down"
]

enum Direction {
	UP,
	DOWN
}

@export var node_to_move: Node
@export var direction := Direction.UP:
	set(value):
		direction = value
		texture_normal = load(TEXTURES[direction])
		tooltip_text = TOOLTIPS[direction]
@export var index_limit := -1

signal moved(neighbor: Node)

func on_pressed() -> void:
	var index := node_to_move.get_index()
	var new_index := -1
	if direction == Direction.UP:
		if index > index_limit:
			new_index = index - 1
	elif index_limit < index_limit or index_limit == -1:
		new_index = index + 1
	if new_index < 0 or new_index >= node_to_move.get_parent().get_child_count():
		return
	if new_index > -1:
		var neighbor := get_parent().get_child(new_index)
		node_to_move.get_parent().move_child(node_to_move, new_index)
		moved.emit(neighbor)
