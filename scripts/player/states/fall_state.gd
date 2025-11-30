extends PlayerState

func enter_state():
	Name = "Falling"
	
func exit_state():
	pass
	
func draw():
	pass
	
func update_state(delta):
	Player.handle_gravity(delta, Player.GRAVITY_FALL)
	Player.horizontal_movement()
	handle_jump_buffer()
	Player.handle_landing()
	Player.handle_jump()
	handle_animations()
	Player.handle_dash()

func handle_animations():
	$"../../AnimatedSprite2D".play("jump")
	Player.handle_flip_h()

func handle_jump_buffer():
	if Player.key_jump:
		Player.jump_buffer_timer.start(Player.JUMP_BUFFER_TIME)
