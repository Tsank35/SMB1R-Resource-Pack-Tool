extends Window

const TITLES := ["View Image", "Set Rect", "Animation Preview"]
const DEFAULT_SIZE := Vector2i(800, 600)
const ZOOM_SPEED := 0.1
const MIN_ZOOM := 0.05
const MAX_ZOOM := 20.0
const DEFAULT_ZOOM_MARGIN := 20

enum ImageMode {
	VIEW,
	RECT,
	ANIMATION
}

var image_mode := ImageMode.VIEW
var is_panning := false
var rect_origin := Vector2i.ZERO
var grid := Vector2(8, 8)
var connected_callable := Callable()

@export_group("Nodes")
@export var image: TextureRect
@export var transparency: TextureRect
@export var selection: SelectionRect
@export var animation: AnimatedSprite2D
@export var camera: Camera2D
@export var rect_hud: CanvasLayer
@export var rect_size: Label
@export var grid_size: Array[SpinBox] = []
@export var animation_hud: CanvasLayer

signal rect_set(rect: Rect2)

func open(texture: Texture2D, use_mode: ImageMode, data := {}, connect_callable := Callable()) -> void:
	if not texture:
		MessageLog.log_error("Invalid image.")
		return
	image_mode = use_mode
	connected_callable = connect_callable
	title = TITLES[image_mode]
	size = DEFAULT_SIZE
	mode = MODE_WINDOWED
	if image_mode == ImageMode.ANIMATION:
		var largest := Vector2.ZERO
		animation.sprite_frames.clear("default")
		for frame: Array in data.frames:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(frame[0], frame[1], frame[2], frame[3])
			animation.sprite_frames.add_frame("default", atlas)
			if atlas.region.size.x > largest.x:
				largest.x = atlas.region.size.x
			if atlas.region.size.y > largest.y:
				largest.y = atlas.region.size.y
		animation.sprite_frames.set_animation_speed("default", data.speed)
		animation.sprite_frames.set_animation_loop("default", data.loop)
		animation.play()
		camera.position = Vector2.ZERO
		fit_camera(largest)
	else:
		image.texture = texture
		image.size = texture.get_size()
		camera.position = texture.get_size() / 2.0
		fit_camera(texture.get_size())
		scale_transparency()
		if image_mode == ImageMode.RECT:
			if data.has("rect"):
				selection.position = data.rect.position
				selection.size = data.rect.size
			grid_size[0].max_value = texture.get_width()
			grid_size[1].max_value = texture.get_height()
			if connected_callable:
				rect_set.connect(connected_callable, ConnectFlags.CONNECT_ONE_SHOT)
	image.visible = image_mode != ImageMode.ANIMATION
	transparency.visible = image_mode != ImageMode.ANIMATION
	selection.visible = image_mode == ImageMode.RECT
	rect_hud.visible = image_mode == ImageMode.RECT
	animation.visible = image_mode == ImageMode.ANIMATION
	animation_hud.visible = image_mode == ImageMode.ANIMATION
	
	popup_centered()

func _process(_delta) -> void:
	if not visible:
		return
	if is_panning:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			is_panning = false
	elif is_mouse_inside() and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		is_panning = true
	if image_mode == ImageMode.RECT:
		rect_size.text = selection.get_rect_string()

func _input(event: InputEvent) -> void:
	if is_mouse_inside():
		if event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					camera.zoom.x += ZOOM_SPEED
					camera.zoom.y += ZOOM_SPEED
					camera.zoom = camera.zoom.clampf(MIN_ZOOM, MAX_ZOOM)
					scale_transparency()
				MOUSE_BUTTON_WHEEL_DOWN:
					camera.zoom.x -= ZOOM_SPEED
					camera.zoom.y -= ZOOM_SPEED
					camera.zoom = camera.zoom.clampf(MIN_ZOOM, MAX_ZOOM)
					scale_transparency()
	if is_panning:
		if event is InputEventMouseMotion:
			camera.position -= event.relative / camera.zoom

func fit_camera(fit_to_size: Vector2) -> void:
	var multiplier := Vector2(size) / content_scale_factor / (fit_to_size + Vector2.ONE * DEFAULT_ZOOM_MARGIN)
	if multiplier.x < multiplier.y:
		camera.zoom = Vector2.ONE * multiplier.x
	else:
		camera.zoom = Vector2.ONE * multiplier.y

func scale_transparency() -> void:
	transparency.scale = Vector2.ONE / camera.zoom
	transparency.size = image.size * camera.zoom

func is_mouse_inside() -> bool:
	if not visible:
		return false
	var mouse_pos := get_mouse_position()
	if mouse_pos.x < 0 or mouse_pos.y < 0:
		return false
	if mouse_pos.x >= size.x or mouse_pos.y >= size.y:
		return false
	return true

func close() -> void:
	is_panning = false
	image.texture = null
	match image_mode:
		ImageMode.RECT:
			if rect_set.is_connected(connected_callable):
				rect_set.disconnect(connected_callable)
		ImageMode.ANIMATION:
			animation.stop()
	connected_callable = Callable()
	hide()

func apply_rect() -> void:
	rect_set.emit(selection.get_rect())
	close()

func replay_animation() -> void:
	animation.set_frame_and_progress(0, 0)
	animation.play()

func set_grid_width(value: float) -> void:
	grid.x = value

func set_grid_height(value: float) -> void:
	grid.y = value
