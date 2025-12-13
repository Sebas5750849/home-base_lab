extends PlayerState
#class_name Grappling

func enter_state():
	Name = "Grappling"
	Player._use_rope()
		
func exit_state():
	pass

func draw():
	pass
	
func update_state(delta):
	Player.velocity = Vector2.ZERO
	Player.handle_grapple()
	if Player.on_rope:
		$"../../AnimatedSprite2D".rotation_degrees = Player.ropebody.rotation_degrees + 180
		#Player.rotation_degrees = Player.ropebody.rotation_degrees + 180
		Player.global_position = Player.ropebody.get_hang_position()
	else:
		$"../../AnimatedSprite2D".rotation_degrees = 0 
	handle_animations()

func handle_animations():
	$"../../AnimatedSprite2D".play("jump")
	Player.handle_flip_h()
