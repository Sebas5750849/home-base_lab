extends Control

signal back

func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_pressed() -> void:
	back.emit()
