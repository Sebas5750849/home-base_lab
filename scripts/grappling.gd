extends PlayerState
#class_name Grappling


func enter_state():
	Name = "Grappling"
	Player._use_rope()
		
func exit_state():
	$"../../AnimatedSprite2D".rotation_degrees = 0
	Player.rc_grapple.target_position = Vector2(74, -125)
func draw():
	pass
	
func update_state(delta):
	Player.velocity = Vector2.ZERO
	Player.handle_grapple()
	if Player.on_rope:
		Player.rotation_degrees = Player.ropebody.rotation_degrees + 180
		Player.global_position = Player.ropebody.get_hang_position()
	else:
			Player.rotation_degrees = 0  # optional: reset if no rope
	handle_animations()
#
#func get_hang_position():
	#return get_node("player_position_marker").global_position

func handle_animations():
	$"../../AnimatedSprite2D".play("jump")
	#Player.handle_flip_h()
