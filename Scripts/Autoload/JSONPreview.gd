extends Window

@export var text_edit: TextEdit

func open(json: Dictionary) -> void:
	text_edit.text = Stringifier.stringify(json)
	popup_centered()

func close() -> void:
	hide()
	text_edit.text = ""
