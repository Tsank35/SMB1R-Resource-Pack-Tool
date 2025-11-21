class_name SelectionRect extends Panel

@export var drag_area: Control

var origin := Vector2i.ZERO
var mouse_pressed := false

func _ready() -> void:
	if drag_area:
		drag_area.gui_input.connect(on_gui_input)

func _process(_delta) -> void:
	if mouse_pressed and visible:
		set_rect(origin, mouse_to_grid())

func on_gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mouse_pressed = true
			origin = mouse_to_grid()

func mouse_to_grid() -> Vector2:
	return (get_global_mouse_position() / ImageWindow.grid).floor() * ImageWindow.grid

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			mouse_pressed = false

func set_rect(from: Vector2, to: Vector2) -> void:
	if drag_area:
		from = from.clamp(Vector2.ZERO, drag_area.size)
		to = to.clamp(Vector2.ZERO, drag_area.size)
	position = from.min(to)
	size = (from - to).abs() + ImageWindow.grid
	if drag_area:
		size = size.clamp(Vector2.ZERO, drag_area.size - position)

func get_rect_string() -> String:
	var string := "X: " + Stringifier.stringify(position.x) + ", Y: " + Stringifier.stringify(position.y)
	string += "\nW: " + Stringifier.stringify(size.x) + ", H: " + Stringifier.stringify(size.y)
	return string
