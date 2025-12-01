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
	Player.horizontal_movement(Player.AIR_ACCELERATION, Player.AIR_DECELERATION)
	handle_jump_buffer()
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
