extends CharacterBody2D

@onready var sprite: Sprite2D = $Icon35

var direction: Vector2
var right_bounds: Vector2
var left_bounds: Vector2
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") 

const SPEED = 400 # whatever dasdh speed is 
const ACCELERATION = 200 


enum States{
	WANDER
}

var current_state = States.WANDER

func _ready():
	left_bounds = self.position + Vector2(-70, 0) # arbitrary values for now
	right_bounds = self.position + Vector2(70, 0)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()

func handle_movement(delta: float):
	if current_state == States.WANDER:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION*delta)
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
		else:
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1,0)
			
			else:
				# if we arent then we flip to moving left
				sprite.flip_h = true
	

func handle_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta				
		
