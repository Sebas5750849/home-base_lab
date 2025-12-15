extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var yes_button = $HBoxContainer/yes
	if yes_button:
		yes_button.grab_focus()

func _on_yes_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Analytics.testing = true
		get_tree().change_scene_to_file("res://scenes/Level scenes/game_explanation.tscn")


func _on_no_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Analytics.testing = false
		get_tree().change_scene_to_file("res://scenes/Level scenes/game_explanation.tscn")
