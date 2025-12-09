extends PlayerState
#class_name Jumping


func enter_state():
	Name = "Jumping"
	Player.velocity.y = PlayerVar.jump_speed
	Player.jump_height_timer.start(PlayerVar.JUMP_HEIGHT_TIME)
	
func exit_state():
	pass
	
func draw():
	pass
	
func update_state(delta):
	Player.handle_gravity(delta)
	Player.horizontal_movement()
	Player.handle_jump()
	Player.handle_grapple()
	handle_jump_to_fall()
	Player.handle_wall_jump()
	Player.handle_dash()
	handle_animations()
	
func handle_jump_to_fall():
	if Player.velocity.y >= 0:
		Player.change_state(States.Falling)
		
func handle_animations():
	$"../../AnimatedSprite2D".play("jump")
	Player.handle_flip_h()
