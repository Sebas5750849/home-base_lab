extends PlayerState

func enter_state():
	Name = "Running_Ice"

func exit_state():
	pass

func draw():
	pass

func update_state(delta):
	Player.handle_falling()
	Player.handle_jump()
	Player.movement_on_ice()
	Player.handle_crouch()
	Player.handle_ice()
	handle_slide()
	handle_animations()
	Player.handle_dash()
	

func handle_slide():
	if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right") and Player.is_on_ice():
		Player.change_state(States.Sliding)

func handle_animations():
	$"../../AnimatedSprite2D".play("run")
	Player.handle_flip_h()
