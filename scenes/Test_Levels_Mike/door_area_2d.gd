extends Area2D


@export var connected_room: String # holds the file path of the room scene we want to load
@export var player_pos: Vector2 # position we want the player to spawn inside the connected room
@export var player_jump_on_enter: bool = false # if we want to jump upon entering the connected room


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("body entered")
		RoomChangeGlobal.activate = true
		print(RoomChangeGlobal.activate)
		RoomChangeGlobal.player_pos = player_pos
		print(RoomChangeGlobal.player_pos)
		RoomChangeGlobal.player_jump_on_enter = player_jump_on_enter
		get_tree().call_deferred("change_scene_to_file", connected_room) # call defered so code inside the function runs at the end of the frame
