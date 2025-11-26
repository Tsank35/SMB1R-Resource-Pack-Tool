class_name AsepriteTag extends DataBlock

const SCENE := "res://Scenes/Components/AsepriteTag.tscn"

@export var is_root := false

var tag_name := "default"
var direction := "forward"
var repeat := 1
var separate := true: set = set_separate
var parent_tag: AsepriteTag

@export_group("Nodes")
@export var label: Label
@export var animation_properties: HBoxContainer
@export var separate_checkbox: CheckBox
@export var duration_input: SpinBox
@export var loop_checkbox: CheckBox
@export var container: VBoxContainer

func _ready() -> void:
	super()
	label.text = tag_name
	if is_root:
		separate_checkbox.queue_free()
		separate_checkbox = null
	else:
		label.text += " [Direction: " + direction.capitalize() + ", Repeat: " + str(repeat) + "]"
		separate = parent_tag.is_root
	duration_input.get_line_edit().expand_to_text_length = true
	default_duration.call_deferred()

func default_duration() -> void:
	if duration_input.value == 0:
		duration_input.value = 100

func add_frame(index: int, data: Dictionary) -> void:
	var frame := Label.new()
	frame.text = "Frame " + str(index + 1) + " [Rect: " + Stringifier.stringify(data.rect) + ", Duration: " + Stringifier.stringify(data.duration) + " ms]"
	frame.set_meta("data", data)
	if data.duration < duration_input.value or duration_input.value == 0:
		duration_input.set_value_no_signal(data.duration)
	container.add_child(frame)

func add_tag(_tag_name: String, data: Dictionary) -> AsepriteTag:
	var tag: AsepriteTag = Global.instantiate(SCENE)
	tag.tag_name = _tag_name
	tag.direction = data.direction
	tag.repeat = data.repeat
	tag.parent_tag = self
	data.block = tag
	container.add_child(tag)
	return tag

func move_to(tag: AsepriteTag) -> void:
	parent_tag = tag
	separate = parent_tag.is_root
	reparent(tag.container, false)

func clear() -> void:
	duration_input.value = 0
	for child: Node in container.get_children():
		child.queue_free()

func get_duration() -> float:
	return duration_input.value

func set_separate(value: bool) -> void:
	separate = value
	animation_properties.visible = separate
	separate_checkbox.set_pressed_no_signal(separate)

func get_data(reversed := false) -> Dictionary:
	var frames := []
	var json := {
		"frames": frames,
		"speed": 1000.0 / duration_input.value,
		"loop": loop_checkbox.button_pressed
	}
	
	var children := container.get_children()
	for r: int in repeat:
		var is_reversed := reversed
		if direction.contains("reverse"):
			is_reversed = not is_reversed
		if (direction.contains("pingpong")) and r % 2 == 1:
			is_reversed = not is_reversed
		
		for i: int in children.size():
			if direction.contains("pingpong"):
				if r > 0 and i == 0:
					continue
				if repeat % 2 == 0 and loop_checkbox.button_pressed:
					if r == repeat - 1 and i == children.size() - 1:
						continue
			
			var child: Node
			if is_reversed:
				child = children[children.size() - i - 1]
			else:
				child = children[i]
			if child is Label:
				var data: Dictionary = child.get_meta("data")
				if not separate:
					duration_input.value = parent_tag.get_duration()
				for d: int in maxi(roundi(data.duration / duration_input.value), 1):
					frames.append(data.rect)
			elif child is AsepriteTag:
				if child.separate:
					continue
				frames.append_array(child.get_data(reversed).frames)
	return json
