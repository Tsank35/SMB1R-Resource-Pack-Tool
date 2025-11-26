class_name SpriteRect extends BoxContainer

var rect := Rect2(): set = set_rect
var texture: Texture2D

@export_group("Nodes")
@export var spin_boxes: Array[SpinBox] = []

signal rect_changed

func set_rect(value: Rect2) -> void:
	rect = value
	var array := get_rect_array()
	for i: int in array.size():
		spin_boxes[i].set_value_no_signal(array[i])
	rect_changed.emit()

func set_rect_from_image() -> void:
	ImageWindow.open(texture, ImageWindow.ImageMode.RECT, {"rect": rect}, set_rect)

func set_rect_from_array(array: Array) -> void:
	var new_rect := Rect2()
	var check := func(i: int) -> bool:
		if array.size() <= i:
			MessageLog.log_error("Rect array is too short.")
			return false
		if array[i] is int or array[i] is float:
			return true
		MessageLog.type_error(TYPE_INT, typeof(array[i]))
		return false
	if check.call(0):
		new_rect.position.x = array[0]
	if check.call(1):
		new_rect.position.y = array[1]
	if check.call(2):
		new_rect.size.x = array[2]
	if check.call(3):
		new_rect.size.y = array[3]
	rect = new_rect

func get_rect_array() -> Array:
	return [rect.position.x, rect.position.y, rect.size.x, rect.size.y]

func set_boundaries(bounds: Vector2) -> void:
	for i: int in spin_boxes.size():
		if i % 2 == 0:
			spin_boxes[i].max_value = bounds.x
		else:
			spin_boxes[i].max_value = bounds.y

func set_enabled(enabled: bool) -> void:
	for spin_box: SpinBox in spin_boxes:
		spin_box.editable = enabled

func copy() -> void:
	Global.clipboard = {"rect": rect}
	Global.clipboard_type = DataBlock.DataType.RECT
	MessageLog.log_message("Copied data.")

func paste() -> void:
	if Global.clipboard:
		if Global.clipboard_type == DataBlock.DataType.RECT:
			rect = Global.clipboard.rect
			MessageLog.log_message("Pasted data.")
		else:
			MessageLog.log_error("Invalid data.")
	else:
		MessageLog.log_error("Clipboard is empty.")

func set_rect_x(value: float) -> void:
	rect.position.x = value

func set_rect_y(value: float) -> void:
	rect.position.y = value

func set_rect_width(value: float) -> void:
	rect.size.x = value

func set_rect_height(value: float) -> void:
	rect.size.y = value
