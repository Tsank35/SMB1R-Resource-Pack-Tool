extends TextureButton

@export var confirm_timer: Timer

signal deletion_confirmed

func on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		confirm_timer.start()
		tooltip_text = "Confirm Deletion"
	else:
		confirm_timer.stop()
		deletion_confirmed.emit()

func on_confirm_timeout() -> void:
	set_pressed_no_signal(false)
	tooltip_text = "Delete"
