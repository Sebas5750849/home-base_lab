extends PlayerState
#class_name Falling


func enter_state():
	Name = "Falling"
		
func exit_state():
	pass
	
func draw():
	pass
	
func update_state(delta):
	Player.handle_gravity(delta, Player.GRAVITY_FALL)
	if above_head_is_clear():
		Player.collision_shape.shape = Player.standing_shape
		Player.collision_shape.position.y = -22
	Player.horizontal_movement(Player.AIR_ACCELERATION, Player.AIR_DECELERATION)
	handle_jump_buffer()
	Player.handle_grapple()
	Player.handle_landing()
	Player.handle_jump()
	Player.handle_wall_jump()
	Player.handle_dash()
	handle_animations()

func handle_animations():
	$"../../AnimatedSprite2D".play("jump")
	Player.handle_flip_h()

func handle_jump_buffer():
	if Player.key_jump:
		Player.jump_buffer_timer.start(Player.JUMP_BUFFER_TIME)

func above_head_is_clear() -> bool:
	return not Player.crouch_ray_1.is_colliding() and not Player.crouch_ray_2.is_colliding()
