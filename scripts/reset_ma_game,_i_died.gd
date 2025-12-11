extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print('you died?')
	get_tree().reload_current_scene()
	PlayerVar.health -= 1
	print('you died btw')
