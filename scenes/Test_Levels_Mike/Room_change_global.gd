extends Node

var activate: bool = false # will tell the player it needs to spawn at a set position

var player_pos: Vector2 # The set position the player must spawn at in the next room
var player_jump_on_enter: bool # For when we enter a room from below and need a vertical boost
