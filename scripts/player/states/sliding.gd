extends PlayerState

func enter_state():
	Name = "Sliding"
	
func exit_state():
	pass

func draw():
	pass

func update_state(delta):
	Player.handle_falling()
	Player.handle_jump()
	Player.handle_crouch()
	Player.movement_on_ice()
	Player.handle_ice()
	handle_animations()
	handle_idle()
	Player.handle_dash()

func handle_idle():
	if Player.velocity.x == 0:
		Player.change_state(States.Idle)

func handle_animations():
	$"../../AnimatedSprite2D".play('idle')
	Player.handle_flip_h()
