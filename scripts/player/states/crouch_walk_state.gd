extends PlayerState
#class_name Crawling


func enter_state():
	Name = "Crawling"
	pass
	
func exit_state():
	if Player.current_state == States.Crouching:
		return
	Player.collision_shape.shape = Player.standing_shape
	Player.collision_shape.position.y = -22
	
func draw():
	pass
	
func update_state(delta):
	Player.handle_falling()
	Player.horizontal_movement(Player.GROUND_ACCELERATION, Player.GROUND_DECELERATION, Player.CROUCH_SPEED_MULTIPLIER)
	return_to_idle()
	handle_animations()
	return_to_crouch()
	Player.handle_roll()
	
#func handle_roll():
	#if Player.key_roll:
		#Player.change_state(States.Rolling)
		
func handle_animations():
	$"../../AnimatedSprite2D".play("crouch_walk")
	Player.handle_flip_h()

func return_to_idle():
	if not Player.key_crouch and above_head_is_clear():
		Player.change_state(States.Idle)

func above_head_is_clear() -> bool:
	return not Player.crouch_ray_1.is_colliding() and not Player.crouch_ray_2.is_colliding()



func return_to_crouch():
	if not (Player.key_left or Player.key_right):
		Player.change_state(States.Crouching)
