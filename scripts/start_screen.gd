extends Control
	
func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ravine_tile_test.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	pass # Replace with function body.
