extends ScrollContainer

const PAGE_OFFSET := 2

var current_page: Control

@export var menu: ItemList
@export var container: VBoxContainer
@export var close_button: TextureButton

func select_page(index: int) -> void:
	if current_page:
		current_page.hide()
	menu.hide()
	menu.deselect(index)
	current_page = container.get_child(index + PAGE_OFFSET)
	current_page.show()
	close_button.show()

func close_page() -> void:
	current_page.hide()
	current_page = null
	close_button.hide()
	menu.show()

func meta_clicked(meta: Variant) -> void:
	if meta.begins_with("https://"):
		OS.shell_open(meta)
	elif meta == "Variations":
		select_page(2)
