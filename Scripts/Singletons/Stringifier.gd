class_name Stringifier

static func stringify(value: Variant, indent := 0) -> String:
	if value is String or value is StringName:
		return '"' + value + '"'
	elif value is float:
		if roundf(value) == value:
			return str(int(value))
	elif value is Array:
		if should_indent(value):
			var string := "["
			indent += 1
			for i: int in value.size():
				if i > 0:
					string += ","
				string += new_line(stringify(value[i], indent), indent)
			indent -= 1
			string += new_line("]", indent)
			return string
		else:
			var string := "["
			for i: int in value.size():
				if i > 0:
					string += ", "
				string += stringify(value[i])
			string += "]"
			return string
	elif value is Dictionary:
		if should_indent(value):
			var keys: Array = value.keys()
			var values: Array = value.values()
			var string := "{"
			indent += 1
			for i: int in value.size():
				if i > 0:
					string += ","
				string += new_line(stringify(keys[i], indent) + ": " + stringify(values[i], indent), indent)
			indent -= 1
			string += new_line("}", indent)
			return string
		elif value.size() == 1:
			return "{" + stringify(value.keys()[0]) + ": " + stringify(value.values()[0]) + "}"
		else:
			return "{}"
	return str(value)

static func new_line(string: String, indent := 0) -> String:
	var pre := "\n"
	for i: int in indent:
		pre += "\t"
	return pre + string

static func should_indent(value: Variant) -> bool:
	if value is Array:
		if value.size() > 1:
			for i in value:
				if not (i is int or i is float):
					return true
		elif value.size() == 1:
			return should_indent(value[0])
	elif value is Dictionary:
		if value.size() > 1:
			return true
		elif value.size() == 1:
			return should_indent(value.keys()[0]) or should_indent(value.values()[0])
	return false
