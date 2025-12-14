extends Node


# constants
const RUNNING_SPEED: float = 200
const JUMP_VELOCITY: float = -400
# const GRAVITY_JUMP: float = 600 # ProjectSettings.get_setting("physics/2d/default_gravity") = 980.0 by default
const GRAVITY_JUMP: float = 1000 # ProjectSettings.get_setting("physics/2d/default_gravity") = 980.0 by default


const GRAVITY_FALL: float = 700
# const DASH_SPEED: float = 700
const DASH_SPEED: float = 600
const ROLL_SPEED: float = 500
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

const DASH_DURATION:float = 0.05
const DASH_COOLDOWN: float = 1
const ROLL_DURATION: float = 0.4
const ROLL_COOLDOWN: float = 1
const JUMP_BUFFER_TIME: float = 0.15
const COYOTE_TIME: float = 0.1
const JUMP_HEIGHT_TIME: float = 0.15
const MAX_JUMPS: int = 2
const INVINCIBILITY_TIME: float = 1

const MAX_HEALTH: float = 5
const MAX_FALL_VELOCITY: float = 1000


var move_speed: float = RUNNING_SPEED
var jump_speed: float = JUMP_VELOCITY

var can_dash: bool
var can_wall_jump: bool
var can_double_jump: bool
var can_roll: bool
var can_grapple: bool

var player_velocity: Vector2

var is_dead: bool = false
var death_count: int
var death_position: Dictionary

var health: float = MAX_HEALTH
var can_take_damage: bool = true
var hearts_list: Array[TextureRect]

var starting_level: Node2D
var lock_starting_level: bool = false

var exit_velocity: Vector2

var current_state = null
var previous_state = null
