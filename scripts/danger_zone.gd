extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and PlayerVar.can_take_damage:
		print("entered danger zone")
		body.is_in_danger = true
		PlayerVar.can_take_damage = false
		body.take_damage()
		body.get_node("Timers/InvinsibilityTimer").start(PlayerVar.INVINCIBILITY_TIME)
	 	


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.is_in_danger = false
