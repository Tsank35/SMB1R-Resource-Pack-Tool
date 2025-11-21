class_name ImageButton extends Button

var atlas := AtlasTexture.new()
var texture: Texture2D:
	set(value):
		texture = value
		update_texture()
var rect := Rect2():
	set(value):
		rect = value
		update_texture()
var use_rect := false:
	set(value):
		use_rect = value
		update_texture()

@export_group("Nodes")
@export var image: TextureRect

func _ready() -> void:
	image.texture = atlas

func _process(_delta) -> void:
	custom_minimum_size.x = size.y

func update_texture() -> void:
	atlas.atlas = texture
	if texture:
		if use_rect:
			atlas.region = rect
		else:
			atlas.region = Rect2(Vector2.ZERO, texture.get_size())
	else:
		atlas.region = Rect2()

func on_pressed() -> void:
	ImageWindow.open(atlas.atlas, ImageWindow.ImageMode.VIEW)
