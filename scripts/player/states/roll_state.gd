extends PlayerState

func enter_state():
	Name = "Rolling"
	Player.velocity.x = Player.facing * Player.ROLL_SPEED
	Player.roll_timer = Player.ROLL_DURATION
	
func exit_state():
	pass
	
func draw():
	pass
	
func update_state(delta):
	Player.roll_timer -= delta
	Player.handle_gravity()
	handle_animations()
	handle_roll_transition()
	
func handle_animations():
	$"../../AnimatedSprite2D".play("roll")
	Player.handle_flip_h()
	
func handle_roll_transition():
	if Player.roll_timer <= 0:
		if Player.is_on_floor():
			Player.change_state(States.Crouching)
		else:
			Player.change_state(States.Falling)
