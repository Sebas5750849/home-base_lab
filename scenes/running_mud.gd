extends PlayerState

func enter_state():
	Name = "Running_Mud"

func exit_state():
	pass

func draw():
	pass

func update_state(delta):
	Player.handle_falling()
	Player.handle_jump()
	Player.movement_on_mud()
	Player.handle_crouch()
	Player.handle_mud()
	handle_animations()
	handle_idle()

func handle_idle():
	if Player.move_direction_x == 0:
		Player.change_state(States.Idle)

func handle_animations():
	$"../../AnimatedSprite2D".play("mud_run")
	Player.handle_flip_h()
