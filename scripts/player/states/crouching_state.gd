extends PlayerState

func enter_state():
	Name = "Crouching"
	Player.collision_shape.shape = Player.crouching_shape
	Player.collision_shape.position.y = -14
	Player.velocity.x = 0
	
func exit_state():
	if Player.current_state == States.Crawling:
		return
	Player.collision_shape.shape = Player.standing_shape
	Player.collision_shape.position.y = -22
	
func draw():
	pass
	
func update_state(delta):
	handle_idle()
	handle_crawl()
	handle_animations()

func handle_idle():
	if not Player.key_crouch and above_head_is_clear(): #and Player.move_direction_x == 0:
		Player.change_state(States.Idle)

func handle_crawl():
	if (Player.key_left or Player.key_right):
		if Player.key_crouch or !above_head_is_clear():
			Player.change_state(States.Crawling)

func above_head_is_clear() -> bool:
	return not Player.crouch_ray_1.is_colliding() and not Player.crouch_ray_2.is_colliding()
	
func handle_animations():
	$"../../AnimatedSprite2D".play("crouch")
	Player.handle_flip_h()
