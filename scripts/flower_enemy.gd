extends CharacterBody2D

# @export var player: CharacterBody2D
@export var SPEED: int = 20
@export var CHASE_SPEED: int = 150
@export var ACCELERATION: int = 300

# const SPEED = 300.0
# const JUMP_VELOCITY = -400
@export var player: CharacterBody2D

# @onready var player = get_parent().get_node("Player")
@onready var sprite:AnimatedSprite2D = $Sprite
@onready var ray_cast: RayCast2D = $Sprite/RayCast2D
@onready var timer = $Timer

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") 
# get the gravity from player this doesnt really matter cuz they are always on the floor  
var direction: Vector2
var right_bounds: Vector2
var left_bounds: Vector2

enum States{
	WANDER, 
	CHASE
}

var current_state = States.WANDER


func _ready():
	left_bounds = self.position + Vector2(-70, 0) # arbitrary values for now
	right_bounds = self.position + Vector2(70, 0)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()
	find_player()

func find_player() -> void:
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider == player:
			chase_player()
		elif current_state == States.CHASE:
			stop_chase()
			
	elif current_state == States.CHASE:
		stop_chase()
	
func chase_player() -> void:
	timer.stop()
	current_state = States.CHASE

func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()
	
func handle_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_movement(delta: float):
	if current_state == States.WANDER:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION*delta)
	else:
		velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELERATION*delta)
	
	move_and_slide()
	
func change_direction():
	if current_state == States.WANDER:
		# we are in the wantder state
		if sprite.flip_h:
			# if we are flipped (moving right) check if we are within the right bound
			if self.position.x <= right_bounds.x:
				direction = Vector2(1,0)
			else:
				# if we arent then we flip to moving left
				sprite.flip_h = false
				ray_cast.target_position = Vector2(-125, 0)
		else:
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1,0)
			
			else:
				# if we arent then we flip to moving left
				sprite.flip_h = true
				ray_cast.target_position = Vector2(125, 0)
	else:
		# we are in the chasing state 
		direction = (player.position - self.position).normalized()
		
		direction = sign(direction)
		if direction.x == 1:
			# if direction is 1 flip to right
			sprite.flip_h = true
			ray_cast.target_position = Vector2(125, 0)
		else:
			sprite.flip_h = false
			ray_cast.target_position = Vector2(-125, 0)
			
func _on_timer_timeout() -> void:
	current_state = States.WANDER
