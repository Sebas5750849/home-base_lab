extends Node2D

var tilesize = 16
var max_swing_degree = 45
var swing_speed = 0.6
var swing_time = 0.0
var swing_direction = 1

func _ready():
	add_to_group("rope")

func _physics_process(delta):
		
	rotation_degrees = 180 + max_swing_degree * sin(swing_time)
	swing_time += delta * swing_speed * PI * 2

func set_rope(startPosition, endPosition, facing_right := true):
	var distance = startPosition.distance_to(endPosition)
	global_position = endPosition
	
	look_at(startPosition)
	rotation_degrees += 90
	
	if facing_right:
		swing_direction = 1.0
	else:
		swing_direction = -1.0
	
	var start_angle_degrees = 180 + max_swing_degree * swing_direction
	swing_time = asin((start_angle_degrees - 180) / max_swing_degree)
	rotation_degrees = start_angle_degrees
	
	for i in int(distance / tilesize) + 1:
		var newRopeTile = $Sprite2D.duplicate()
		add_child(newRopeTile)
		newRopeTile.position = Vector2(0, -(i * tilesize))
		
	var marker_node = Marker2D.new()
	marker_node.name = "player_position_marker"
	add_child(marker_node)
	marker_node.global_position = startPosition
	
func get_hang_position():
	return get_node("player_position_marker").global_position
