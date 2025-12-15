extends CharacterBody2D


#region constants and variables
# node references
@onready var sprite = $AnimatedSprite2D

@onready var collision_shape = $CollisionShape2D
@onready var area_2d = $Area2D

# raycasts
@onready var crouch_ray_1 = $CrouchRaycast1
@onready var crouch_ray_2 = $CrouchRaycast2
@onready var rc_bottom_right = $Raycasts/WallJump/RCBottomRight
@onready var rc_bottom_left = $Raycasts/WallJump/RCBottomLeft
@onready var rc_down = $Raycasts/Terrain/RCDown
@onready var rc_grapple = $Raycasts/Grapple/RCGrapple

# states
@onready var States = $StateMachine

# Timers
@onready var coyote_timer = $Timers/CoyoteTimer
@onready var jump_buffer_timer = $Timers/JumpBufferTimer
@onready var jump_height_timer = $Timers/JumpHeightTimer
@onready var dash_cooldown_timer = $Timers/DashCooldownTimer
@onready var roll_colldown_timer = $Timers/RollCooldownTimer
@onready var dash_timer = $Timers/DashTimer
@onready var roll_timer = $Timers/RollTimer
@onready var invincibility_timer = $Timers/InvinsibilityTimer

# levels
@onready var current_level = $".."

# Interaction
@onready var all_interactions = [] 
# handles the interactions so that they are organized
# when interaction is entered it will be added to array but remember all other current 
# interactions
@onready var InteractLabel = $InteractionComponents/InteractLabel

# External collision shapes
var standing_shape = preload("res://resources/standing_collision_shape.tres")
var crouching_shape = preload("res://resources/crouching_collision_shape.tres")

# External scenes
const ROPE = preload("res://scenes/Player/rope.tscn")

var move_direction_x = 0
var jumps: int = 0
var wall_direction: Vector2 = Vector2.ZERO
var facing: int = 1

var dash_cooldown: float = 0.0
var dash_direction: float = 1
var roll_cooldown: float = 0.0
var roll_direction: float = 1

var can_coyote_jump: bool = false
var jump_buffered: bool = false

var invincibility_time: float = 1

var accel = 3
var decel = 2 

var on_rope = false
var ropebody

# key inputs
var key_jump = false
var key_jump_pressed = false
var key_up = false
var key_left = false
var key_right = false
var key_down = false
var key_dash = false
var key_crouch = false
var key_grapple = false

# states


var is_in_danger: bool = false

#region main game loop
func _ready() -> void:
	# Make sure raycasts dont collide with player
	rc_bottom_left.add_exception(self)
	rc_bottom_right.add_exception(self)
	rc_down.add_exception(self)
	rc_grapple.add_exception(self)
	crouch_ray_1.add_exception(self)
	crouch_ray_2.add_exception(self)
	update_interactions()
	
	for child_state in States.get_children():
		child_state.States = States
		child_state.Player = self
		
	if PlayerVar.previous_state == null and PlayerVar.current_state == null:
		PlayerVar.previous_state = States.Idle
		PlayerVar.current_state = States.Idle
	
	
	
	print("current_state = ", PlayerVar.current_state)
	print("previous_state = ", PlayerVar.previous_state)
	print(current_level.name)
	
	if not PlayerVar.lock_starting_level:
		PlayerVar.starting_level = current_level
	
	velocity = PlayerVar.exit_velocity
	
	#region switching levels
	if RoomChangeGlobal.activate:
		print("activated")
		global_position = RoomChangeGlobal.player_pos
		if RoomChangeGlobal.player_jump_on_enter:
			velocity.y = PlayerVar.JUMP_VELOCITY
		RoomChangeGlobal.activate = false
	#endregion
	
	#region initialize health "bar"	
	var hearts_parent = $HealthBar/HBoxContainer
	PlayerVar.hearts_list = []
	for child in hearts_parent.get_children():
		PlayerVar.hearts_list.append(child)
	update_heart_display()
	#endregion
	
	PlayerVar.can_take_damage = true
	is_in_danger = false
		
func _physics_process(delta: float) -> void:
	get_input_state()
	
	if dash_cooldown > 0:
		dash_cooldown -= delta
	if roll_cooldown > 0:
		roll_cooldown -= delta
	
	PlayerVar.current_state.update_state(delta)
	
	if Input.is_action_just_pressed("damage"):
		take_damage()
	
	PlayerVar.player_velocity = velocity
	move_and_slide()

func _process(delta: float) -> void:
	check_level()
	check_dead()

func change_state(new_state):
	if new_state != null:
		PlayerVar.previous_state = PlayerVar.current_state
		PlayerVar.current_state = new_state
		PlayerVar.previous_state.exit_state()
		PlayerVar.current_state.enter_state()
		print("State chaged from: " + PlayerVar.previous_state.Name + \
			" to " + PlayerVar.current_state.Name )	
#endregion

#region custom function

func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y = max(velocity.y, -100)

func get_wall_direction():
	if rc_bottom_left.is_colliding():
		wall_direction = Vector2.LEFT
	elif rc_bottom_right.is_colliding():
		wall_direction = Vector2.RIGHT
	else:
		wall_direction = Vector2.ZERO

func get_input_state():
	key_jump = Input.is_action_just_pressed("jump")
	key_jump_pressed = Input.is_action_pressed("jump")
	key_up = Input.is_action_pressed("ui_up")
	key_left = Input.is_action_pressed("move_left")
	key_right = Input.is_action_pressed("move_right")
	key_down = Input.is_action_pressed("ui_down")
	key_dash = Input.is_action_just_pressed("dash")
	key_crouch = Input.is_action_pressed("crouch")
	key_grapple = Input.is_action_just_pressed("grapple")

	if key_right: facing = 1
	if key_left: facing = -1

func handle_ice():
	if key_crouch:
		return
	if is_on_ice() and PlayerVar.current_state != States.RunningIce and (key_left or key_right):
		change_state(States.RunningIce)
	elif is_on_ice() and PlayerVar.current_state != States.Sliding and (!key_left and !key_right):
		change_state(States.Sliding)
	elif not is_on_ice() and (PlayerVar.current_state == States.RunningIce):
		change_state(States.Running)
	elif not is_on_ice() and PlayerVar.current_state == States.Sliding:
		change_state(States.Idle)

func handle_mud():
	if key_crouch:
		return
	if is_on_mud() and PlayerVar.current_state != States.RunningMud:
		change_state(States.RunningMud)
	elif not is_on_mud() and (PlayerVar.current_state == States.RunningMud):
		change_state(States.Running)

func handle_dash():
	if key_dash and dash_cooldown <= 0 and PlayerVar.can_dash:
		change_state(States.Dashing)

func handle_roll():
	if key_dash and roll_cooldown <= 0 and PlayerVar.current_state == States.Crawling and PlayerVar.can_roll:
		print(PlayerVar.can_roll)
		change_state(States.Rolling)

func handle_wall_jump():
	get_wall_direction()
	if (key_jump or jump_buffer_timer.time_left > 0) and wall_direction != Vector2.ZERO and PlayerVar.can_wall_jump:
		print("Wall Jump")
		change_state(States.WallJump)

func handle_gravity(delta, gravity: float = PlayerVar.GRAVITY_JUMP):
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y >= PlayerVar.MAX_FALL_VELOCITY:
			velocity.y = PlayerVar.MAX_FALL_VELOCITY

func handle_jump():
	if is_on_floor():
		if key_jump:
			jumps += 1
			change_state(States.Jumping)
		elif jump_buffer_timer.time_left > 0:
			jumps += 1
			change_state(States.Jumping)
	elif !on_rope:
		if key_jump and 0 < jumps and jumps < PlayerVar.MAX_JUMPS and PlayerVar.can_double_jump:
			jumps += 1
			change_state(States.Jumping)
		elif coyote_timer.time_left > 0:
			if key_jump and jumps < PlayerVar.MAX_JUMPS:
				coyote_timer.stop()
				jumps += 1
				change_state(States.Jumping)

func handle_falling():
	if not is_on_floor() and not on_rope:
		coyote_timer.start(PlayerVar.COYOTE_TIME)
		change_state(States.Falling)

func handle_landing():
	if is_on_floor():
		jumps = 0
		change_state(States.Idle)

func horizontal_movement(acceleration: float = PlayerVar.GROUND_ACCELERATION, deceleration: float = PlayerVar.GROUND_DECELERATION, multiplier: float = 1):
	move_direction_x = Input.get_axis("move_left", "move_right")
	if move_direction_x != 0:
		velocity.x = move_toward(velocity.x, move_direction_x * PlayerVar.move_speed * multiplier, acceleration)
	else:
		velocity.x = move_toward(velocity.x, move_direction_x * PlayerVar.move_speed * multiplier, deceleration)

func handle_grapple():
	if key_jump and on_rope:
		print("Detaching")
		_remove_rope()
		velocity.y = -PlayerVar.JUMP_VELOCITY
		change_state(States.Jumping)
		return
	
	if key_grapple and on_rope:
		print("Detaching")
		_remove_rope()
		change_state(States.Falling)
		return

	if key_grapple and not on_rope and PlayerVar.current_state != States.Grappling and PlayerVar.can_grapple:
		if rc_grapple.is_colliding():
			print("Starting grapple")
			change_state(States.Grappling)
	
	elif on_rope and (rc_bottom_left.is_colliding() or rc_bottom_right.is_colliding() or rc_down.is_colliding() or crouch_ray_1.is_colliding() or crouch_ray_2.is_colliding()):
		_remove_rope()
		change_state(States.Falling)
		return

func handle_crouch():
	if is_on_floor() and key_crouch:
		change_state(States.Crouching)

func handle_flip_h():
	sprite.flip_h = facing < 1
	var x_target = 150
	if facing < 1:
		rc_grapple.target_position.x = -x_target 
	else:
		rc_grapple.target_position.x = x_target 

func is_on_ice():
	var collider = rc_down.get_collider()
	if not collider:
		return false
	return collider.name == ("IceBlocks")

func movement_on_ice():
	var movement_direction_x = Input.get_axis("move_left", "move_right")
	var target_speed = movement_direction_x * PlayerVar.RUNNING_SPEED
	
	if movement_direction_x != 0:
		if velocity.x < target_speed:
			velocity.x = min(velocity.x + accel, target_speed)
		elif velocity.x > target_speed:
			velocity.x = max(velocity.x - accel, target_speed)
	else:
		if velocity.x > 0:
			velocity.x = max(velocity.x - decel, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + decel, 0)

func is_on_mud():
	var collider = rc_down.get_collider()
	if not collider:
		return false
	return collider.name == ("MudBlocks")

func movement_on_mud(acceleration: float = PlayerVar.GROUND_ACCELERATION, deceleration: float = PlayerVar.GROUND_DECELERATION, multiplier: float = PlayerVar.MUD_SPEED_MULTIPLIER):
	move_direction_x = Input.get_axis("move_left", "move_right")
	if move_direction_x != 0:
		velocity.x = move_toward(velocity.x, move_direction_x * PlayerVar.move_speed * multiplier, acceleration)
	else:
		velocity.x = move_toward(velocity.x, move_direction_x * PlayerVar.move_speed * multiplier, deceleration)

func _use_rope():
	if not rc_grapple.is_colliding():
		return
	on_rope = true
	var collidingPoint = rc_grapple.get_collision_point()
	var playerPosition = global_position + Vector2(12, -25)

	var ropeNode = ROPE.instantiate()
	get_parent().add_child(ropeNode)
	ropeNode.set_rope(playerPosition, collidingPoint, facing > 0)
	ropebody = ropeNode

func _remove_rope():
	on_rope = false
	var rope = get_tree().get_first_node_in_group("rope")
	if rope:
		rope.queue_free()
	ropebody = null
#endregion

func check_level():
	if current_level.name.begins_with("linlevel"):
		if current_level.name == "linlevel_0":
			return
		elif current_level.name == "linlevel_1":
			PlayerVar.can_dash = true 
		elif current_level.name == "linlevel_2":
			PlayerVar.can_dash = true 
			PlayerVar.can_wall_jump = true
		elif current_level.name == "linlevel_3":
			PlayerVar.can_dash = true 
			PlayerVar.can_wall_jump = true
			PlayerVar.can_double_jump = true
		elif current_level.name == "linlevel_4":
			PlayerVar.can_dash = true 
			PlayerVar.can_wall_jump = true
			PlayerVar.can_double_jump = true
			PlayerVar.can_roll = true
		else:
			PlayerVar.can_dash = true 
			PlayerVar.can_wall_jump = true
			PlayerVar.can_double_jump = true
			PlayerVar.can_roll = true
			PlayerVar.can_grapple = true

func take_damage():
	if Analytics.testing:
		var current_pos = global_position
		var lvl_name = current_level.name
		Analytics.send_damage_event("Anonymous", current_pos, lvl_name)
	if PlayerVar.health > 0:
		PlayerVar.health -= 1
		update_heart_display()
	print(PlayerVar.health)
	
	
		
func update_heart_display():
	for i in range(PlayerVar.hearts_list.size()):
		PlayerVar.hearts_list[i].visible = i < PlayerVar.health
		

func check_dead():
	if PlayerVar.health <= 0:
		# send data to supabase
		if Analytics.testing:
			var current_pos = global_position
			var lvl_name = current_level.name
			Analytics.send_death_event("Anonymous", current_pos, lvl_name)
		# get_tree().reload_current_scene()
		# get_tree().call_deferred("change_scene_to_file", "res://scenes/Menus/HomeScreenScenes/StartScreen.tscn")

		get_tree().reload_current_scene()
		PlayerVar.death_count += 1
		PlayerVar.health = PlayerVar.MAX_HEALTH

func _on_invinsibility_timer_timeout() -> void:
	PlayerVar.can_take_damage = true

## Interaction Methods 


func _on_interaction_area_area_entered(area: Area2D) -> void:
	all_interactions.insert(0, area)
	update_interactions()


func _on_interaction_area_area_exited(area: Area2D) -> void:
	all_interactions.erase(area)
	update_interactions()

func update_interactions():
	if all_interactions:
		InteractLabel.text = all_interactions[0].interact_label
	else:
		InteractLabel.text = ""
		
