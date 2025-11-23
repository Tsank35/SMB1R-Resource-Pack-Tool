class_name RandomChoice extends DataBlock

var source: VariationComponent
var random_branch: RandomBranch

@export_group("Nodes")
@export var custom_label: LineEdit

func _ready() -> void:
	super()
	source = Global.instantiate(VariationBlock.COMPONENTS[VariationBlock.ComponentType.SOURCE][Global.asset_type])
	source.variation_block = random_branch.variation_block
	source.random_choice = self
	content_container.add_child(source)

func set_custom_label(text: String) -> void:
	custom_label.text = text

func get_custom_label() -> String:
	return custom_label.text

func custom_label_changed() -> void:
	Global.sources_changed.emit()

func get_json(remove_redundant := true) -> Dictionary:
	return {"choice": source.get_json(remove_redundant)}

func apply_json(json: Dictionary) -> void:
	source.apply_json(json)
