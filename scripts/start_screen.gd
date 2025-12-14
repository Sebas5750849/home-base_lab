extends Control
	
func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level scenes/ravine_tile_test.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	var options = preload("res://scenes/Menus/options_menu.tscn").instantiate()
	add_child(options)

	options.back.connect(func():
		options.queue_free()
	)
