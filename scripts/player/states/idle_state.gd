extends PlayerState
#class_name Idle


func enter_state():
	Name = "Idle"
	
func exit_state():
	pass
	
func draw():
	pass
	
func update_state(delta):
	Player.handle_jump()
	Player.handle_falling()
	Player.handle_crouch()
	Player.horizontal_movement()
	handle_animations()
	if Player.move_direction_x != 0:
		Player.change_state(States.Running)
	
func handle_animations():
	$"../../AnimatedSprite2D".play("idle")
	Player.handle_flip_h()
