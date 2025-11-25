class_name AsepriteImport extends Window

@export var root_block: AsepriteTag

signal aseprite_imported(data: Dictionary)

func import() -> void:
	var data := {}
	for tag: Node in get_tree().get_nodes_in_group("Tags"):
		if tag is AsepriteTag:
			if tag.separate:
				var json: Dictionary = tag.get_data()
				if json.frames:
					data.merge({tag.tag_name: json})
	aseprite_imported.emit(data)
	close()

func close() -> void:
	hide()
	root_block.clear()

func open(path: String) -> void:
	var json := Global.read_json(path)
	if json.has("frames"):
		var frame_data := []
		if json.frames is Dictionary:
			frame_data = Global.get_value_of_type({"": json.frames.values()}, "", TYPE_ARRAY, null, TYPE_DICTIONARY)
		elif json.frames is Array:
			frame_data = Global.get_value_of_type(json, "frames", TYPE_ARRAY, null, TYPE_DICTIONARY)
		else:
			MessageLog.log_error("Invalid frame data.")
		
		var frames: Array[Dictionary] = []
		for i: int in frame_data.size():
			var frame = frame_data[i]
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
				frames.append({
					"rect": rect,
					"duration": Global.get_value_of_type(frame, "duration", TYPE_INT),
					"tags": []
				})
			else:
				MessageLog.type_error(TYPE_DICTIONARY, typeof(frame))
		
		var tag_data: Array = Global.get_value_of_type(Global.get_value_of_type(json, "meta", TYPE_DICTIONARY), "frameTags", TYPE_ARRAY, null, TYPE_DICTIONARY)
		var tags := {}
		for tag: Dictionary in tag_data:
			var tag_name: String = Global.get_value_of_type(tag, "name", TYPE_STRING)
			var data := {
				"from": Global.get_value_of_type(tag, "from", TYPE_INT),
				"to": Global.get_value_of_type(tag, "to", TYPE_INT),
				"direction": Global.get_value_of_type(tag, "direction", TYPE_STRING),
				"repeat": maxi(int(Global.get_value_of_type(tag, "repeat", TYPE_STRING)), 1),
				"block": null
			}
			for i: int in data.to - data.from + 1:
				if i >= frames.size():
					continue
				frames[data.from + i].tags.append(tag_name)
			tags.merge({tag_name: data})
		
		root_block.clear()
		var current := root_block
		var current_tags := []
		for i: int in frames.size():
			var frame := frames[i]
			if frame.tags:
				var list := current_tags.duplicate()
				list.sort_custom(func(a: String, b: String) -> bool:
					var tag_a: Dictionary = tags.get(a)
					var tag_b: Dictionary = tags.get(b)
					if tag_a.from == tag_b.from:
						return tag_a.to < tag_b.to
					return tag_a.from > tag_b.from
				)
				
				var done := false
				while not done:
					if list.is_empty():
						done = true
					else:
						for j: int in list.size():
							var tag: String = list[j]
							if not frame.tags.has(tag):
								current_tags.erase(tag)
								if j == 0:
									current = current.parent_tag
								else:
									var tag_block: AsepriteTag = tags.get(list[j]).block
									var child_block: AsepriteTag = tags.get(list[j - 1]).block
									child_block.move_to(tag_block.parent_tag)
									var data: Dictionary = tags.get(current.tag_name)
									for f: int in i - data.from:
										tag_block.add_frame(data.from + f, frames[data.from + f])
								list.remove_at(j)
								break
							elif j == list.size() - 1:
								done = true
				for tag: String in frame.tags:
					if not current_tags.has(tag):
						current_tags.append(tag)
						current = current.add_tag(tag, tags.get(tag))
			else:
				current = root_block
				current_tags = []
			current.add_frame(i, frames[i])
		popup_centered()
	else:
		MessageLog.log_error("No frame data found.")
