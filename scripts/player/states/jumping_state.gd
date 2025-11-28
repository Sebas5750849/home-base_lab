extends PlayerState

func enter_state():
	Name = "Jumping"
	Player.velocity.y = Player.jump_speed
	
func exit_state():
	pass
	
func draw():
	pass
	
func update_state(delta):
	Player.handle_gravity(delta)
	Player.horizontal_movement()
	Player.handle_jump()
	Player.handle_dash()
	handle_jump_to_fall()
	handle_animations()
	
func handle_jump_to_fall():
	if Player.velocity.y >= 0:
		Player.change_state(States.Falling)
		
func handle_animations():
	$"../../AnimatedSprite2D".play("jump")
	Player.handle_flip_h()
