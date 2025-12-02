extends CharacterBody2D


#region constants and variables
# constants
const RUNNING_SPEED: float = 200
const GROUND_ACCELERATION: float = 45
const GROUND_DECELERATION: float = 25
const AIR_ACCELERATION: float = 0
const AIR_DECELERATION: float = 0
const JUMP_VELOCITY: float = -400
const GRAVITY_JUMP: float = 980 # ProjectSettings.get_setting("physics/2d/default_gravity") = 980.0 by default
const GRAVITY_FALL: float = 1000
const DASH_SPEED: float = 600
const DASH_DURATION:float = 0.3
const DASH_COOLDOWN: float = 1
const ROLL_SPEED: float = 200
const ROLL_DURATION: float = 0.4
const ROLL_COOLDOWN: float = 0.6
const CROUCH_SPEED_MULTIPLIER: float = 0.35
const JUMP_BUFFER_TIME: float = 0.15
const MAX_JUMPS: int = 2

# variables
var move_speed: float = RUNNING_SPEED
var jump_speed: float = JUMP_VELOCITY
var move_direction_x = 0
var jumps: int = 0
var facing: int = 1

var dash_timer: float = 0.0
var dash_cooldown: float = 0.0
var dash_direction: float = 1
var roll_timer: float = 0.0
var roll_cooldown: float = 0.0
var roll_direction: float = 1

var can_coyote_jump: bool = false
var jump_buffered: bool = false

# node references
@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var crouch_ray_1 = $CrouchRaycast1
@onready var crouch_ray_2 = $CrouchRaycast2
@onready var coyote_timer = $Timers/CoyoteTimer
@onready var jump_buffer_timer = $Timers/JumpBufferTimer
@onready var jump_height_timer = $Timers/JumpHeightTimer
@onready var States = $StateMachine

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

# Collision shapes
var standing_shape = preload("res://resources/standing_collision_shape.tres")
var crouching_shape = preload("res://resources/crouching_collision_shape.tres")
#endregion

#region main game loop
func _ready() -> void:
	for child_state in States.get_children():
		child_state.States = States
		child_state.Player = self
	previous_state = States.Idle
	current_state = States.Idle
	print("current_state = ", current_state)
	print("previous_state = ", previous_state)

func _physics_process(delta: float) -> void:
	get_input_state()
	if dash_cooldown > 0:
		dash_cooldown -= delta
	if roll_cooldown > 0:
		roll_cooldown -= delta
	
	current_state.update_state(delta)
	
	var was_on_floor = is_on_floor()
	
	# Started to fall
	if was_on_floor and !is_on_floor() and velocity.y >= 0:
		can_coyote_jump = true
		coyote_timer.start()
	
	# Touched ground
	if !was_on_floor and is_on_floor():
		if jump_buffered:
			jump_buffered = false
			jump()
	
	move_and_slide()
	
func change_state(new_state):
	if new_state != null:
		previous_state = current_state
		current_state = new_state
		previous_state.exit_state()
		current_state.enter_state()
		print("State chaged from: " + previous_state.Name + " to " + current_state.Name )	
#endregion

#region custom function
func jump():
	if is_on_floor() or can_coyote_jump: 
		velocity.y = JUMP_VELOCITY
		if can_coyote_jump:
			can_coyote_jump = false
	else:
		if !jump_buffered:
			jump_buffered = true
			jump_buffer_timer.start()

# Timers
func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false

func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false

func _on_jump_height_timer_timeout() -> void:
	if !Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y = max(velocity.y, -100)

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

func handle_gravity(delta, gravity: float = GRAVITY_JUMP):
	if not is_on_floor() and (can_coyote_jump == false):
		velocity.y += gravity * delta

func handle_dash():
	if key_dash and dash_cooldown <= 0:
		change_state(States.Dashing)

func handle_jump():
	if key_jump and jumps < MAX_JUMPS:
		jumps += 1
		change_state(States.Jumping)
		
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

func handle_falling():
	if not is_on_floor() and current_state not in [States.Dashing, States.Jumping]:
		change_state(States.Falling)

func handle_crouch():
	if is_on_floor() and key_crouch:
		change_state(States.Crouching)

func handle_flip_h():
	sprite.flip_h = facing < 1

#endregion
