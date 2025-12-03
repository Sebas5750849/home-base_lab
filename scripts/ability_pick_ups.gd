extends Node

@onready var PlayerScene = $"../Player"



func _on_dash_body_entered(body: Node2D) -> void:
	print("entered dash")
	PlayerScene.can_dash = true


func _on_wall_jump_body_entered(body: Node2D) -> void:
	print("entered wall jump")
	PlayerScene.can_wall_jump = true

func _on_double_jump_body_entered(body: Node2D) -> void:
	print("entered double jump")
	PlayerScene.can_double_jump = true

func _on_roll_body_entered(body: Node2D) -> void:
	print("entered roll")
	PlayerScene.can_roll = true
