extends PlayerState
#class_name Dashing


func enter_state():
	Name = "Dashing"
	Player.velocity.x = Player.facing * Player.DASH_SPEED
	Player.velocity.y = 0
	Player.dash_timer = Player.DASH_DURATION
	
func exit_state():
	Player.dash_cooldown = Player.DASH_COOLDOWN
	Player.dash_timer = Player.DASH_DURATION
	
func draw():
	pass
	
func update_state(delta):
	Player.dash_timer -= delta
	handle_animations()
	handle_dash_transition()
	
func handle_animations():
	$"../../AnimatedSprite2D".play("dash")
	Player.handle_flip_h()
	#
#func handle_dash_to_fall():
	#if not Player.is_on_floor() and Player.dash_timer <= 0:
		#Player.change_state(States.Falling)
#
#func handle_dash_to_idle():
	#if Player.is_on_floor() and Player.dash_timer <= 0:
		#Player.change_state(States.Idle)

func handle_dash_transition():
	if Player.dash_timer <= 0:
		if Player.is_on_floor():
			Player.change_state(States.Idle)
		elif not Player.is_on_floor():
			Player.change_state(States.Falling)
