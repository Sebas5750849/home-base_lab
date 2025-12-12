extends Area2D

@export var ability: String


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if ability == "dash":
			PlayerVar.can_dash = true
		elif ability == "wall_jump":
			PlayerVar.can_wall_jump = true
		elif ability == "double_jump":
			PlayerVar.can_double_jump = true
		elif ability == "roll":
			PlayerVar.can_roll = true
		elif ability == "grapple":
			PlayerVar.can_grapple = true
		queue_free()
