class_name RandomBranch extends VariationComponent

const RANDOM_CHOICE := "res://Scenes/Components/Variation/RandomChoice.tscn"

func add_choice(json := {}) -> void:
	var choice: RandomChoice = Global.instantiate(RANDOM_CHOICE)
	choice.random_branch = self
	add_child(choice)
	
	var label := ""
	if json:
		choice.apply_json(json)
		if json.has("label") and json.label is String:
			label = json.label
	if not label:
		label = str(get_choices().size())
	choice.set_custom_label(label)

func get_choices() -> Array[RandomChoice]:
	var choices: Array[RandomChoice] = []
	for child: Node in get_children():
		if child is RandomChoice:
			choices.append(child)
	return choices

func get_json(remove_redundant := true) -> Dictionary:
	var choices := []
	for choice: RandomChoice in get_choices():
		choices.append(choice.get_json(remove_redundant).values()[0])
	if remove_redundant:
		if choices.is_empty():
			MessageLog.log_warning("Skipped empty random branch.", self)
			return {}
		elif choices.size() == 1:
			MessageLog.log_warning("Only one source was found, so the source was returned on its own.", self)
			return choices[0]
	return {"choices": choices}

func apply_json(json: Dictionary) -> void:
	var choices: Array = Global.get_value_of_type(json, "choices", TYPE_ARRAY, self, TYPE_DICTIONARY)
	for choice in choices:
		add_choice(choice)
