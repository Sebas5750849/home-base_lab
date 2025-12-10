extends Node2D

var tilesize = 16
var max_swing_degree = 45
var swing_speed = 0.5  # swings per second
var swing_time = 0.0   # internal time counter

#var tilesize = 16
##var max_swing_degree = 45
#var change_rotation = -1.5
#var swing_speed = 90 

func _ready():
	add_to_group("rope")

func _physics_process(delta):
	rotation_degrees = 180 + max_swing_degree * sin(swing_time)
	swing_time += delta * swing_speed * PI * 2  # full swing cycle
	#rotation_degrees = 180 + max_swing_degree * sin(swing_time)
	#rotation_degrees += change_rotation * swing_speed * delta
	#
	#if rotation_degrees >= 180 + max_swing_degree:
		#change_rotation = -1
	#elif rotation_degrees <= 180 - max_swing_degree:
		#change_rotation = 1
	
func set_rope(startPosition, endPosition):
	swing_time = -PI / 2
	var distance = startPosition.distance_to(endPosition)
	global_position = endPosition
	
	look_at(startPosition)
	rotation_degrees += 90
	
	#if rotation_degrees < 180:
		#change_rotation = 1
	
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
