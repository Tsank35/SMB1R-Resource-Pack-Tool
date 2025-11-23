class_name AnimationBlock extends DataBlock

const FRAME := "res://Scenes/Components/Sprite/AnimationFrame.tscn"

var collection: AnimationCollection

@export_group("Nodes")
@export var name_input: LineEdit
@export var speed_input: SpinBox
@export var loop_button: TextureButton
@export var frame_container: VBoxContainer

func add_frame(rect := []) -> void:
	var frame: AnimationFrame = Global.instantiate(FRAME)
	frame.source = collection.source
	frame_container.add_child(frame)
	if rect:
		frame.set_rect_array(rect)

func clear_frames() -> void:
	for frame: AnimationFrame in get_frames():
		frame.queue_free()

func get_frames() -> Array[AnimationFrame]:
	var frames: Array[AnimationFrame] = []
	for child: Node in frame_container.get_children():
		if child is AnimationFrame:
			frames.append(child)
	return frames

func is_empty() -> bool:
	return get_frames().is_empty()

func preview_animation() -> void:
	var source := collection.source
	if not source and Global.reference_source is SpriteSource:
		source = Global.reference_source
	if source:
		var texture: Texture2D
		if source.texture:
			if source.use_full_image:
				texture = source.texture
			else:
				var atlas := AtlasTexture.new()
				atlas.region = source.rect
				atlas.atlas = source.texture
				texture = atlas
		ImageWindow.open(texture, ImageWindow.ImageMode.ANIMATION, get_json().values()[0])
	else:
		MessageLog.log_error("No reference found.")

func set_animation_name(anim_name: String) -> void:
	name_input.text = anim_name

func get_animation_name() -> String:
	return name_input.text

func get_json(_remove_redundant := true) -> Dictionary:
	var frames := []
	for frame: AnimationFrame in get_frames():
		var rect := frame.rect
		frames.append([rect.position.x, rect.position.y, rect.size.x, rect.size.y])
	var json := {
		"frames": frames,
		"speed": speed_input.value,
		"loop": loop_button.button_pressed
	}
	return {get_animation_name(): json}

func apply_json(json: Dictionary) -> void:
	clear_frames()
	
	var frames: Array = Global.get_value_of_type(json, "frames", TYPE_ARRAY, self, TYPE_ARRAY)
	for frame in frames:
		var valid := true
		if frame.size() != 4:
			if frame.size() < 4:
				MessageLog.log_error("Not enough frame dimensions given.", self)
			else:
				MessageLog.log_error("Too many frame dimensions given.", self)
			valid = false
		if valid:
			for i in frame:
				if i is not int and i is not float:
					MessageLog.log_error("Expected a number array, but found a " + Global.type_name(typeof(i)) + " value instead.", self)
					valid = false
					break
		if valid:
			add_frame(frame)
	if not json.has("frames"):
		MessageLog.log_error("No frames found.", self)
	
	speed_input.value = Global.get_value_of_type(json, "speed", TYPE_INT, self)
	if json.has("loop"):
		loop_button.button_pressed = Global.get_value_of_type(json, "loop", TYPE_BOOL, self)
	else:
		loop_button.button_pressed = true
