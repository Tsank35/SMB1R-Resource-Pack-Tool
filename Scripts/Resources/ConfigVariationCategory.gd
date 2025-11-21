class_name ConfigVariationCategory extends VariationCategory

@export var key := ""

static func create(option: String, values: Array) -> ConfigVariationCategory:
	var category := ConfigVariationCategory.new()
	category.resource_name = option
	category.key = "config:" + option
	for value: String in values:
		var variation := Variation.new()
		variation.resource_name = value
		variation.key = value
		category.variations.append(variation)
	return category
