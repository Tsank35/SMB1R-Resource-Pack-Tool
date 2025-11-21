class_name VariationCategory extends Resource

@export var variations: Array[Variation] = []

func has_key(key: String) -> bool:
	for variation: Variation in variations:
		if variation.is_custom:
			if variation.key and key.begins_with(variation.key):
				return true
		elif key == variation.key:
			return true
	return false
