extends ScrollContainer

var current_page: Control

@export var menu: ItemList
@export var page_container: MarginContainer
@export var close_button: TextureButton

func select_page(index: int) -> void:
	menu.hide()
	menu.deselect(index)
	current_page = page_container.get_child(index)
	current_page.show()
	close_button.show()

func close_page() -> void:
	current_page.hide()
	current_page = null
	close_button.hide()
	menu.show()

func meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
