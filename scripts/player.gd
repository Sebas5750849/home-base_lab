extends CharacterBody2D

# Constants
const SPEED = 200.0
const JUMP_VELOCITY = -500.0
const DASH_SPEED = 450.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 0.4
const ROLL_SPEED = 200
const ROLL_DURATION = 0.4
const ROLL_COOLDOWN = 0.6
const CROUCH_SPEED = 0.35

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# States
var is_crouching = false
var stuck_under_object = false
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0
var dash_direction = 1
var is_rolling = false
var roll_timer = 0.0
var roll_cooldown = 0.0
var roll_direction = 1

var can_coyote_jump = false
var jump_buffered = false

# Node references
@onready var sprite = $AnimatedSprite2D
@onready var cshape = $CollisionShape2D
@onready var ray1 = $CrouchRaycast1
@onready var ray2 = $CrouchRaycast2
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var jump_height_timer = $JumpHeightTimer

# Collision shapes
var standing_shape = preload("res://resources/standing_collision_shape.tres")
var crouching_shape = preload("res://resources/crouching_collision_shape.tres")

# Main physics
func _physics_process(delta: float) -> void:
	# Reduce cooldowns
	if dash_cooldown > 0:
		dash_cooldown -= delta
	if roll_cooldown > 0:
		roll_cooldown -= delta
	
	var direction = Input.get_axis("move_left", "move_right")

	# Handle roll and dash separately
	if is_rolling:
		_handle_roll(delta)
		move_and_slide()
		return
	if is_dashing:
		_handle_dash(delta)
		move_and_slide()
		return
		
	 #Gravity when falling
	if not is_on_floor() && (can_coyote_jump == false):
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and not is_crouching:
		jump_height_timer.start()
		jump()
		
	# Crouch
	if is_on_floor():
		if Input.is_action_pressed("crouch"):
			_enter_crouch()
	if Input.is_action_just_released("crouch"):
		if _above_head_is_clear():
			_exit_crouch()
		else:
			stuck_under_object = true

		if stuck_under_object and _above_head_is_clear() and not Input.is_action_pressed("crouch"):
			stuck_under_object = false
			_exit_crouch()
	if stuck_under_object and _above_head_is_clear() and not Input.is_action_pressed("crouch"):
		stuck_under_object = false
		_exit_crouch()

	#Dash
	if Input.is_action_just_pressed("dash") and not is_crouching and dash_cooldown <= 0:
		if direction != 0:
			_start_dash(direction)

	# Roll
	if Input.is_action_just_pressed("dash") and roll_cooldown <= 0 and is_crouching and is_on_floor():
		if direction != 0:
			_start_roll(direction)

	# Movement
	var move_speed = SPEED
	if is_crouching:
		move_speed *= CROUCH_SPEED

	if direction != 0:
		velocity.x = direction * move_speed
		if not is_dashing and not is_rolling:
			sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	# Started to fall
	if was_on_floor && !is_on_floor() && velocity.y >= 0:
		can_coyote_jump = true
		coyote_timer.start()
	
	# Touched ground
	if !was_on_floor && is_on_floor():
		if jump_buffered:
			jump_buffered = false
			jump()
	
	_play_ground_animations(direction)

func jump():
	if is_on_floor() || can_coyote_jump: 
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

# Animations
func _play_ground_animations(direction):
	if is_rolling or is_dashing:
		return
		
	if not is_on_floor():
		sprite.play("jump")
		return

	if is_crouching:
		if direction == 0:
			sprite.play("crouch")
		else:
			sprite.play("crouch_walk")
		return

	if direction == 0:
		sprite.play("idle")
	else:
		sprite.play("run")

# Crouching/uncrouching
func _enter_crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_shape
	cshape.position.y = -9

func _exit_crouch():
	if not is_crouching:
		return
	is_crouching = false
	cshape.shape = standing_shape
	cshape.position.y = -16

func _above_head_is_clear() -> bool:
	return !ray1.is_colliding() and !ray2.is_colliding()

# Dashing
func _start_dash(dir):
	is_dashing = true
	dash_direction = sign(dir)
	dash_timer = DASH_DURATION
	dash_cooldown = DASH_COOLDOWN

	velocity.y = 0
	velocity.x = dash_direction * DASH_SPEED

	sprite.play("dash")

func _handle_dash(delta):
	dash_timer -= delta
	velocity.x = dash_direction * DASH_SPEED
	velocity.y = 0

	if dash_timer <= 0:
		is_dashing = false

# Rolling
func _start_roll(dir):
	is_rolling = true
	roll_direction = sign(dir)
	roll_timer = ROLL_DURATION
	roll_cooldown = ROLL_COOLDOWN

	velocity.x = roll_direction * ROLL_SPEED

func _handle_roll(delta):
	roll_timer -= delta
	velocity.x = roll_direction * ROLL_SPEED
	if not is_on_floor():
		velocity.y += gravity * delta
	sprite.play("roll")
	
	if roll_timer <= 0:
		is_rolling = false
		if !_above_head_is_clear():
			stuck_under_object = true
		elif !Input.is_action_pressed("crouch"):
			_exit_crouch()
