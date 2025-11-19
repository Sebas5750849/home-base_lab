extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ACCELERATION = 0.1
const DECELERATION = 0.1
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var gc := $GrappleController


func _physics_process(delta: float) -> void:
	# Debug
	# Displays in realtime if an action is pressed
	#var right = Input.is_action_pressed("move_right")
	#var left = Input.is_action_pressed("move_left")
	#var grapple = Input.is_action_pressed("grapple")
	## print("left:", left, " | right:", right, " | grapple:", grapple)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") && (is_on_floor() || gc.launched):
		velocity.y += JUMP_VELOCITY
		gc.retract()

	# Get the direction (-1, 0, 1)
	var direction := Input.get_axis("move_left", "move_right")
	
	#Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false 
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Play animation
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION)

	move_and_slide()
