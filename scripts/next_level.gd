extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("body entered")
	if body.is_in_group("Player"):
		print("collided with player. Lets go next level")
		var current_scene_file = get_tree().current_scene.scene_file_path
		print(current_scene_file)
		var next_level_number = current_scene_file.to_int() + 1
		print(next_level_number)
