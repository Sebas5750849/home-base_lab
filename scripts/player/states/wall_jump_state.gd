extends PlayerState
class_name WallJumping


var last_wall_direction: Vector2
var should_enable_wall_kick: bool

func enter_state():
	Name = "Wall_Jump"
	Player.velocity.y = PlayerVar.WALL_JUMP_VELOCITY
	last_wall_direction = Player.wall_direction
	should_only_jump_button_wall_kick(true)
	
	
func exit_state():
	pass
	
func draw():
	pass
	
func update_state(delta):
	Player.get_wall_direction() # for ending state if we hit a wall
	Player.handle_gravity(delta, PlayerVar.GRAVITY_JUMP)
	handle_wall_kick_movement()
	handle_wall_jump_end()
	handle_animations()
	
	
func handle_animations():
	if not Player.key_left and not Player.key_right and should_enable_wall_kick:
		$"../../AnimatedSprite2D".play("Wall_Kick")
		Player.sprite.flip_h = Player.velocity.x > 0
	else:
		$"../../AnimatedSprite2D".play("Wall_Jump")
		Player.sprite.flip_h = Player.velocity.x < 0

func handle_wall_jump_end():
	# end if at jump_peak
	if Player.velocity.y >= PlayerVar.WALL_JUMP_Y_SPEED_PEAK:
		Player.change_state(States.Falling)
	
	# cancel if we hit a wall
	if Player.wall_direction != last_wall_direction and Player.wall_direction != Vector2.ZERO:
		Player.change_state(States.Falling)


func should_only_jump_button_wall_kick(should_enable: bool):
	should_enable_wall_kick = should_enable
	if should_enable:
		if Player.key_left or Player.key_right:
			Player.velocity.x = PlayerVar.WALL_JUMP_H_SPEED * Player.wall_direction.x * -1
		else:
			if Player.jumps == PlayerVar.MAX_JUMPS:
				Player.velocity.x = PlayerVar.WALL_JUMP_H_SPEED * Player.wall_direction.x * -1
			else:
				Player.change_state(States.Falling)
	else:
		Player.velocity.x = PlayerVar.WALL_JUMP_H_SPEED * Player.wall_direction.x * -1

func handle_wall_kick_movement():
	if not Player.key_left and not Player.key_right:
		# no input means wall kick, so slow horizontal movement to zero to just move away from the wall a little
		Player.velocity.x = move_toward(Player.velocity.x, 0, PlayerVar.WALL_KICK_ACCELERATION)
	else:
		# allow player to move to the opposite wall at full speed
		if last_wall_direction == Vector2.LEFT and Player.key_right:
			Player.horizontal_movement(PlayerVar.WALL_KICK_ACCELERATION, PlayerVar.WALL_KICK_DECELERATION)
		elif last_wall_direction == Vector2.RIGHT and Player.key_left:
			Player.horizontal_movement(PlayerVar.WALL_KICK_ACCELERATION, PlayerVar.WALL_KICK_DECELERATION)
