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
