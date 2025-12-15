extends Area2D


@export var ability_to_get: String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if ability_to_get == "dash":
			PlayerVar.can_dash = true
		elif ability_to_get == "wall jump":
			PlayerVar.can_wall_jump = true
		elif ability_to_get == "double_jump":
			PlayerVar.can_double_jump = true
		elif ability_to_get == "roll":
			PlayerVar.can_roll = true
		elif ability_to_get == "grapple":
			PlayerVar.can_grapple = true
		queue_free()
