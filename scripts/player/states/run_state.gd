extends PlayerState
#class_name Running


func enter_state():
	Name = "Running"
	
func exit_state():
	pass
	
func draw():
	pass
	
func update_state(delta):
	Player.handle_falling()
	Player.handle_jump()
	Player.horizontal_movement()
	Player.handle_crouch()
	handle_animations()
	handle_idle()
	Player.handle_dash()
	
func handle_idle():
	if Player.move_direction_x == 0:
		Player.change_state(States.Idle)
		
func handle_animations():
	$"../../AnimatedSprite2D".play("run")
	Player.handle_flip_h()
