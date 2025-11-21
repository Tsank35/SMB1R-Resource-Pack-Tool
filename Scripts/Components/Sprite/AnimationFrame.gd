class_name AnimationFrame extends VBoxContainer

var rect := Rect2():
	set(value):
		rect = value
		update_frame()
var source: SpriteSource:
	get:
		if not source and Global.reference_source is SpriteSource:
			return Global.reference_source
		return source

@export_group("Nodes")
@export var image: ImageButton
@export var spin_boxes: Array[SpinBox] = []

func _ready() -> void:
	update_frame()
	Global.reference_changed.connect(update_frame)
	image.use_rect = true

func set_rect_from_image() -> void:
	if source:
		var texture := source.get_cropped_texture()
		ImageWindow.open(texture, ImageWindow.ImageMode.RECT, {"rect": rect}, set_rect)

func set_rect(value: Rect2) -> void:
	rect = value
	update_spin_boxes()

func set_rect_array(array: Array) -> void:
	set_rect(Global.get_rect_from_array(array))

func update_frame() -> void:
	if source:
		image.texture = source.get_cropped_texture()
		image.rect = rect
	else:
		image.texture = null

func update_spin_boxes() -> void:
	spin_boxes[0].set_value_no_signal(rect.position.x)
	spin_boxes[1].set_value_no_signal(rect.position.y)
	spin_boxes[2].set_value_no_signal(rect.size.x)
	spin_boxes[3].set_value_no_signal(rect.size.y)

func set_x(value: float) -> void:
	rect.position.x = value

func set_y(value: float) -> void:
	rect.position.y = value

func set_width(value: float) -> void:
	rect.size.x = value

func set_height(value: float) -> void:
	rect.size.y = value
