extends PlayerState
#class_name Rolling


func enter_state():
	Name = "Rolling"
	Player.velocity.x = Player.facing * PlayerVar.ROLL_SPEED
	Player.roll_timer = PlayerVar.ROLL_DURATION
	Player.collision_shape.shape = Player.crouching_shape
	Player.collision_shape.position.y = -14
	
func exit_state():
	Player.roll_cooldown = PlayerVar.ROLL_COOLDOWN
	Player.roll_timer = PlayerVar.ROLL_DURATION
	if Player.current_state == States.Crouching:
		return
	Player.collision_shape.shape = Player.standing_shape
	Player.collision_shape.position.y = -22
	
func draw():
	pass
	
func update_state(delta):
	Player.roll_timer -= delta
	Player.handle_gravity(delta)
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
