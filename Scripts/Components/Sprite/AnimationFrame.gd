class_name AnimationFrame extends SpriteRect

var source: SpriteSource:
	get:
		if not source and Global.reference_source:
			return Global.reference_source
		return source

@export_group("Nodes")
@export var image: ImageButton

func _ready() -> void:
	update_frame()
	Global.reference_changed.connect(update_frame)
	image.use_rect = true

func set_rect_from_image() -> void:
	if source:
		texture = source.get_cropped_texture()
		super()
	else:
		MessageLog.log_error("No source to reference.")

func update_frame() -> void:
	if source:
		image.texture = source.get_cropped_texture()
		image.rect = rect
	else:
		image.texture = null
