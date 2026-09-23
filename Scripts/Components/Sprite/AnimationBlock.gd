class_name AnimationBlock extends DataBlock

const FRAME := "res://Scenes/Components/Sprite/AnimationFrame.tscn"

var collection: AnimationCollection
var is_link := false: set = set_is_link

@export_group("Nodes")
@export var name_input: LineEdit
@export var speed_input: SpinBox
@export var loop_checkbox: CheckBox
@export var link_checkbox: CheckBox
@export var preview_button: TextureButton
@export var link_dropdown: OptionButton
@export var property_container: HBoxContainer
@export var frame_container: VBoxContainer
@export var link_container: HBoxContainer

func _ready() -> void:
	collection.children_changed.connect(update_links)

func add_frame(rect := []) -> void:
	var frame: AnimationFrame = Global.instantiate(FRAME)
	frame.source = collection.source
	frame_container.add_child(frame)
	if rect:
		frame.set_rect_from_array(rect)

func clear_frames() -> void:
	for frame: AnimationFrame in get_frames():
		frame.queue_free()

func get_frames() -> Array[AnimationFrame]:
	var frames: Array[AnimationFrame] = []
	for child: Node in frame_container.get_children():
		if child is AnimationFrame and not child.is_queued_for_deletion():
			frames.append(child)
	return frames

func is_empty() -> bool:
	return get_frames().is_empty()

func update_links() -> void:
	link_dropdown.clear()
	for animation: AnimationBlock in collection.get_animations():
		if animation == self:
			continue
		link_dropdown.add_item(animation.get_animation_name())

func select_link(link: String) -> void:
	for i: int in link_dropdown.item_count:
		if link_dropdown.get_item_text(i) == link:
			link_dropdown.select(i)
			return
	MessageLog.log_error("Invalid link: " + link + ".", self)

func set_is_link(value: bool) -> void:
	is_link = value
	property_container.visible = not is_link
	preview_button.visible = not is_link
	frame_container.visible = not is_link
	link_container.visible = is_link

func preview_animation() -> void:
	var source := collection.source
	if not source and Global.reference_source:
		source = Global.reference_source
	if source:
		var texture: Texture2D
		if source.texture:
			texture = source.get_cropped_texture()
		ImageWindow.open(texture, ImageWindow.ImageMode.ANIMATION, get_json().values()[0])
	else:
		MessageLog.log_error("No reference found.")

func set_animation_name(anim_name: String) -> void:
	name_input.text = anim_name

func get_animation_name() -> String:
	return name_input.text

func get_json(_remove_redundant := true) -> Dictionary:
	if is_link:
		return {get_animation_name(): {"link": link_dropdown.get_item_text(link_dropdown.selected)}}
	
	var frames := []
	for frame: AnimationFrame in get_frames():
		frames.append(frame.get_rect_array())
	var json := {
		"frames": frames,
		"speed": speed_input.value,
		"loop": loop_checkbox.button_pressed
	}
	return {get_animation_name(): json}

func apply_json(json: Dictionary) -> void:
	clear_frames()
	is_link = json.has("link")
	link_checkbox.set_pressed_no_signal(is_link)
	if is_link:
		select_link.call_deferred(Global.get_value_of_type(json, "link", TYPE_STRING))
	else:
		var frames: Array = Global.get_value_of_type(json, "frames", TYPE_ARRAY, self, TYPE_ARRAY)
		for frame in frames:
			add_frame(frame)
		if not json.has("frames"):
			MessageLog.log_error("No frames found.", self)
		
		speed_input.value = Global.get_value_of_type(json, "speed", TYPE_INT, self)
		if json.has("loop"):
			loop_checkbox.button_pressed = Global.get_value_of_type(json, "loop", TYPE_BOOL, self)
		else:
			loop_checkbox.button_pressed = true
