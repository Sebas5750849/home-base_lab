extends PlayerState

func enter_state():
	Name = "Crawling"
	pass
	
func exit_state():
	if Player.current_state == States.Crouching:
		return
	Player.collision_shape.shape = Player.standing_shape
	Player.collision_shape.position.y = -16
	
func draw():
	pass
	
func update_state(delta):
	Player.handle_falling()
	Player.horizontal_movement(Player.GROUND_ACCELERATION, Player.GROUND_DECELERATION, Player.CROUCH_SPEED_MULTIPLIER)
	return_to_idle()
	handle_animations()
	
func handle_roll():
	if Player.key_roll:
		Player.change_state(States.Rolling)
		
func handle_animations():
	$"../../AnimatedSprite2D".play("crouch_walk")
	Player.handle_flip_h()

func return_to_idle():
	if not Player.key_crouch:
		Player.change_state(States.Idle)
