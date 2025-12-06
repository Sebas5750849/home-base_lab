extends CharacterBody2D


#region constants and variables
# node references
@onready var sprite = $AnimatedSprite2D

@onready var collision_shape = $CollisionShape2D

# raycasts
@onready var crouch_ray_1 = $CrouchRaycast1
@onready var crouch_ray_2 = $CrouchRaycast2
@onready var rc_bottom_right = $Raycasts/WallJump/RCBottomRight
@onready var rc_bottom_left = $Raycasts/WallJump/RCBottomLeft
@onready var rc_down = $Raycasts/Terrain/RCDown
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

# levels
@onready var current_level = $".."

# External collision shapes
var standing_shape = preload("res://resources/standing_collision_shape.tres")
var crouching_shape = preload("res://resources/crouching_collision_shape.tres")

# constants
const RUNNING_SPEED: float = 200
const JUMP_VELOCITY: float = -400
# const GRAVITY_JUMP: float = 600 # ProjectSettings.get_setting("physics/2d/default_gravity") = 980.0 by default
const GRAVITY_JUMP: float = 1000 # ProjectSettings.get_setting("physics/2d/default_gravity") = 980.0 by default


const GRAVITY_FALL: float = 700
# const DASH_SPEED: float = 700
const DASH_SPEED: float = 600
const ROLL_SPEED: float = 200
const CROUCH_SPEED_MULTIPLIER: float = 0.35
const MUD_SPEED_MULTIPLIER = 0.3
const WALL_JUMP_VELOCITY: float = -400
const WALL_JUMP_H_SPEED: float = 200 # speed with which you jump away from the wall
const WALL_JUMP_Y_SPEED_PEAK: float = 0 # vertical speed at which wall jump will transition to falling

const GROUND_ACCELERATION: float = 40
const GROUND_DECELERATION: float = 50
const AIR_ACCELERATION: float = 15
const AIR_DECELERATION: float = 20
const WALL_KICK_ACCELERATION: float = 4
const WALL_KICK_DECELERATION: float = 5

const DASH_DURATION:float = 0.0001
const DASH_COOLDOWN: float = 1
const ROLL_DURATION: float = 0.4
const ROLL_COOLDOWN: float = 1
const JUMP_BUFFER_TIME: float = 0.15
const COYOTE_TIME: float = 0.1
const JUMP_HEIGHT_TIME: float = 0.15
const MAX_JUMPS: int = 2

# variables
var move_speed: float = RUNNING_SPEED
var jump_speed: float = JUMP_VELOCITY
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

var accel = 3
var decel = 2 

# key inputs
var key_jump = false
var key_jump_pressed = false
var key_up = false
var key_left = false
var key_right = false
var key_down = false
var key_dash = false
var key_crouch = false

# states
var current_state = null
var previous_state = null

# ability booleans
var can_dash: bool = false
var can_wall_jump: bool = false
var can_double_jump: bool = false
var can_roll: bool = false

#region main game loop
func _ready() -> void:
	for child_state in States.get_children():
		child_state.States = States
		child_state.Player = self
	previous_state = States.Idle
	current_state = States.Idle
	print("current_state = ", current_state)
	print("previous_state = ", previous_state)
	print(current_level.name)

func _physics_process(delta: float) -> void:
	get_input_state()
	if dash_cooldown > 0:
		dash_cooldown -= delta
	if roll_cooldown > 0:
		roll_cooldown -= delta
	
	current_state.update_state(delta)
	
	move_and_slide()

func _process(delta: float) -> void:
	check_level()

func change_state(new_state):
	if new_state != null:
		previous_state = current_state
		current_state = new_state
		previous_state.exit_state()
		current_state.enter_state()
		print("State chaged from: " + previous_state.Name + \
			" to " + current_state.Name )	
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

	if key_right: facing = 1
	if key_left: facing = -1

func handle_ice():
	if key_crouch:
		return
	if is_on_ice() and current_state != States.RunningIce and (key_left or key_right):
		change_state(States.RunningIce)
	elif is_on_ice() and current_state != States.Sliding and (!key_left and !key_right):
		change_state(States.Sliding)
	elif not is_on_ice() and (current_state == States.RunningIce):
		change_state(States.Running)
	elif not is_on_ice() and current_state == States.Sliding:
		change_state(States.Idle)

func handle_mud():
	if key_crouch:
		return
	if is_on_mud() and current_state != States.RunningMud:
		change_state(States.RunningMud)
	elif not is_on_mud() and (current_state == States.RunningMud):
		change_state(States.Running)

func handle_dash():
	if key_dash and dash_cooldown <= 0 and can_dash:
		change_state(States.Dashing)

func handle_roll():
	if key_dash and roll_cooldown <= 0 and current_state == States.Crawling and can_roll:
		change_state(States.Rolling)

func handle_wall_jump():
	get_wall_direction()
	if (key_jump or jump_buffer_timer.time_left > 0) and wall_direction != Vector2.ZERO and can_wall_jump:
		print("Wall Jump")
		change_state(States.WallJump)

func handle_gravity(delta, gravity: float = GRAVITY_JUMP):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if is_on_floor():
		if key_jump:
			jumps += 1
			change_state(States.Jumping)
		elif jump_buffer_timer.time_left > 0:
			jumps += 1
			change_state(States.Jumping)
	else:
		if key_jump and 0 < jumps and jumps < MAX_JUMPS and can_double_jump:
			jumps += 1
			change_state(States.Jumping)
		elif coyote_timer.time_left > 0:
			if key_jump and jumps < MAX_JUMPS:
				coyote_timer.stop()
				jumps += 1
				change_state(States.Jumping)

func handle_falling():
	if not is_on_floor():
		coyote_timer.start(COYOTE_TIME)
		change_state(States.Falling)

func handle_landing():
	if is_on_floor():
		jumps = 0
		change_state(States.Idle)

func horizontal_movement(acceleration: float = GROUND_ACCELERATION, deceleration: float = GROUND_DECELERATION, multiplier: float = 1):
	move_direction_x = Input.get_axis("move_left", "move_right")
	if move_direction_x != 0:
		velocity.x = move_toward(velocity.x, move_direction_x * move_speed * multiplier, acceleration)
	else:
		velocity.x = move_toward(velocity.x, move_direction_x * move_speed * multiplier, deceleration)

func handle_crouch():
	if is_on_floor() and key_crouch:
		change_state(States.Crouching)

func handle_flip_h():
	sprite.flip_h = facing < 1

func is_on_ice():
	var collider = rc_down.get_collider()
	if not collider:
		return false
	return collider.name == ("IceBlocks")

func movement_on_ice():
	var movement_direction_x = Input.get_axis("move_left", "move_right")
	var target_speed = movement_direction_x * RUNNING_SPEED
	
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

func movement_on_mud(acceleration: float = GROUND_ACCELERATION, deceleration: float = GROUND_DECELERATION, multiplier: float = MUD_SPEED_MULTIPLIER):
	move_direction_x = Input.get_axis("move_left", "move_right")
	if move_direction_x != 0:
		velocity.x = move_toward(velocity.x, move_direction_x * move_speed * multiplier, acceleration)
	else:
		velocity.x = move_toward(velocity.x, move_direction_x * move_speed * multiplier, deceleration)

#endregion

func check_level():
	if current_level.name == "linlevel_1":
		can_dash = true 
	elif current_level.name == "linlevel_2":
		can_dash = true 
		can_wall_jump = true
	elif current_level.name == "linlevel_3":
		can_dash = true 
		can_wall_jump = true
		can_double_jump = true
	elif current_level.name == "linlevel_4":
		can_dash = true 
		can_wall_jump = true
		can_double_jump = true
		can_roll = true
	elif current_level.name == "linlevel_5":
		can_dash = true 
		can_wall_jump = true
		can_double_jump = true
		can_roll = true
