extends Area2D


# coins = 0

func _on_body_entered(body: Node2D) -> void:
	# coins += 1
	queue_free()
