class_name PropertyBlock extends DataBlock

const PROPERTY := "res://Scenes/Components/Sprite/SpriteProperty.tscn"

@export var source: SpriteSource

@export_group("Nodes")
@export var property_container: VBoxContainer

func _ready() -> void:
	super()
	if is_empty():
		set_collapsed(true)

func add_property(json := {}) -> void:
	var property: SpriteProperty = Global.instantiate(PROPERTY)
	property_container.add_child(property)
	if json:
		property.apply_json(json)

func clear() -> void:
	for property: SpriteProperty in get_properties():
		property.queue_free()

func get_properties() -> Array[SpriteProperty]:
	var properties: Array[SpriteProperty] = []
	for child: Node in property_container.get_children():
		if child is SpriteProperty:
			properties.append(child)
	return properties

func is_empty() -> bool:
	return get_properties().is_empty()

func get_json(remove_redundant := true) -> Dictionary:
	var json := {}
	var names := []
	for property: SpriteProperty in get_properties():
		var property_json := property.get_json()
		var property_name = property_json.keys()[0]
		if names.has(property_name) and remove_redundant:
			MessageLog.log_warning("Skipped property, for another property with the same name exists.", property)
		else:
			json.merge(property_json)
			names.append(property_name)
	if not json:
		return {}
	return {"properties": json}

func apply_json(json: Dictionary) -> void:
	clear()
	for key in json.keys():
		if key is String:
			add_property({key: json[key]})
		else:
			MessageLog.type_error(TYPE_STRING, typeof(key), self)
	set_collapsed(is_empty())
