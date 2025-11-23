class_name AnimationCollection extends DataBlock

const ANIMATION_BLOCK := "res://Scenes/Components/Sprite/AnimationBlock.tscn"

@export var source: SpriteSource
@export var is_override := false

@export_group("Nodes")
@export var animation_container: VBoxContainer

func _ready() -> void:
	super()
	if is_empty():
		set_collapsed(true)

func add_animation(anim_name := "", json := {}) -> void:
	var animation: AnimationBlock = Global.instantiate(ANIMATION_BLOCK)
	animation.collection = self
	animation_container.add_child(animation)
	if anim_name:
		animation.set_animation_name(anim_name)
	if json:
		animation.apply_json(json)

func clear() -> void:
	for animation: AnimationBlock in get_animations():
		animation.queue_free()

func get_animations() -> Array[AnimationBlock]:
	var animations: Array[AnimationBlock] = []
	for child: Node in animation_container.get_children():
		if child is AnimationBlock:
			animations.append(child)
	return animations

func is_empty() -> bool:
	return get_animations().is_empty()

func import_aseprite(path: String, speed: float, seperate_tags: bool) -> void:
	var json := Global.read_json(path)
	if json.has("frames"):
		var frames := []
		if json.frames is Dictionary:
			frames = Global.get_value_of_type({"": json.frames.values()}, "", TYPE_ARRAY, null, TYPE_DICTIONARY)
		elif json.frames is Array:
			frames = Global.get_value_of_type(json, "frames", TYPE_ARRAY, null, TYPE_DICTIONARY)
		else:
			MessageLog.log_error("Invalid frame data.")
		
		var data := []
		for i in frames.size():
			var frame = frames[i]
			if frame is Dictionary:
				var rect := [0, 0, 0, 0]
				var rect_data: Dictionary = Global.get_value_of_type(frame, "frame", TYPE_DICTIONARY)
				if rect_data:
					rect = [
						Global.get_value_of_type(rect_data, "x", TYPE_INT),
						Global.get_value_of_type(rect_data, "y", TYPE_INT),
						Global.get_value_of_type(rect_data, "w", TYPE_INT),
						Global.get_value_of_type(rect_data, "h", TYPE_INT)
					]
				var duration: int = roundi(Global.get_value_of_type(frame, "duration", TYPE_INT) / speed)
				data.append({
					"rect": rect,
					"duration": duration
				})
			else:
				MessageLog.type_error(TYPE_DICTIONARY, typeof(frame))
		
		var tags: Array = Global.get_value_of_type(Global.get_value_of_type(json, "meta", TYPE_DICTIONARY), "frameTags", TYPE_ARRAY, null, TYPE_DICTIONARY)
		for tag in tags:
			var from: int = Global.get_value_of_type(tag, "from", TYPE_INT)
			var to: int = Global.get_value_of_type(tag, "to", TYPE_INT)
			var direction: String = Global.get_value_of_type(tag, "direction", TYPE_STRING)
			var repeat := maxi(int(Global.get_value_of_type(tag, "repeat", TYPE_STRING)), 1)
			
			var tag_frames := []
			for i in to - from + 1:
				var tag_frame = data.pop_at(from)
				if seperate_tags:
					tag_frame.merge({"tag": Global.get_value_of_type(tag, "name", TYPE_STRING)})
				tag_frames.append(tag_frame)
			if direction.contains("reverse"):
				tag_frames.reverse()
			
			if direction.contains("pingpong"):
				var all_frames := []
				for i in repeat:
					if i % 2 == 0:
						all_frames.append_array(tag_frames.duplicate())
					else:
						var reversed := tag_frames.duplicate()
						reversed.reverse()
						reversed.remove_at(0)
						reversed.pop_back()
						all_frames.append_array(reversed)
				for i in all_frames.size():
					data.insert(from + i, all_frames[i])
			else:
				var all_frames := []
				for i in repeat:
					all_frames.append_array(tag_frames.duplicate())
				for i in all_frames.size():
					data.insert(from + i, all_frames[i])
		
		var animations := {}
		for frame: Dictionary in data:
			var animation: String = frame.get("tag", "default")
			var animation_data := {}
			if animations.has(animation):
				animation_data = animations.get(animation)
			else:
				animation_data = {
					"frames": [],
					"speed": 1000.0 / speed
				}
				animations.merge({animation: animation_data})
			for i in frame.duration:
				animation_data.frames.append(frame.rect)
		apply_json(animations)
	else:
		MessageLog.log_error("No frame data found.")

func get_json(remove_redundant := true) -> Dictionary:
	var json := {}
	var names := []
	for animation: AnimationBlock in get_animations():
		var anim_json := animation.get_json(remove_redundant)
		var anim_name = anim_json.keys()[0]
		if names.has(anim_name) and remove_redundant:
			MessageLog.log_warning("Skipped animation, for another animation with the same name exists.", animation)
		else:
			json.merge(anim_json)
			names.append(anim_name)
	if not json:
		return {}
	if is_override:
		return {"animation_overrides": json}
	return {"animations": json}

func apply_json(json: Dictionary) -> void:
	clear()
	for key in json.keys():
		if key is String:
			add_animation(key, Global.get_value_of_type(json, key, TYPE_DICTIONARY))
		else:
			MessageLog.type_error(TYPE_STRING, typeof(key), self)
	set_collapsed(is_empty())
