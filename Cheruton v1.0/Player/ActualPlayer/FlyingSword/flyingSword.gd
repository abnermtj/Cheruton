extends KinematicBody2D

const SPEED_THROW_START = 2000
const SPEED_RETURN = 1450
const MAX_AIR_TIME = .6
const SPIN_SPEED = 2 # spins /s
const Y_LEVEL_FACTOR = 1.6 # swords tends to the player.pos.y during return

onready var sword_state = sword_states.HIDDEN
enum sword_states { SHOOT = 0, HIT = 1, RETURN = 2, HIDDEN = 3}

onready var bodyRotation = $bodyRotation
onready var airSprite = $bodyRotation/air
onready var hitSprite = $bodyRotation/hit

var velocity
var angular_velocity
var cur_player_pos
var state
var active
var air_timer

signal sword_result

func _ready():
	bodyRotation.visible = false
	state = sword_states.HIDDEN
	angular_velocity = SPIN_SPEED


func _on_flyingSword_command(command, arg):
	hitSprite.visible = false
	airSprite.visible = true
	bodyRotation.visible = true

	if command == 0:
		set_collision_mask_bit(0,1)
		global_position =  DataResource.dict_player.player_pos
		active = true
		air_timer = MAX_AIR_TIME
		velocity = arg.normalized() * SPEED_THROW_START # arg is direction
		state = sword_states.SHOOT
	elif command == 1:
		state = sword_states.RETURN

func _physics_process(delta):
	if active:
		match state:
			sword_states.SHOOT:
				bodyRotation.rotate(angular_velocity)
				air_timer -= delta
				if air_timer < 0 :
					state = sword_states.RETURN
					return

				var col = move_and_collide(velocity*delta)

				if col:
					hitSprite.visible = true
					airSprite.visible = false
					state = sword_states.HIT
					emit_signal("sword_result", 0, global_position)

			sword_states.RETURN:
				set_collision_mask_bit(0,0)
				bodyRotation.rotate(angular_velocity)
				var direction = cur_player_pos - global_position # tip to player
				velocity = direction.normalized() * SPEED_RETURN + Vector2(0,Y_LEVEL_FACTOR * (cur_player_pos.y-global_position.y))
				velocity = velocity.normalized() * SPEED_RETURN
				move_and_collide(velocity * delta)

				if (global_position - cur_player_pos).length() < 20:
					state = sword_states.HIDDEN
			sword_states.HIDDEN:
				bodyRotation.visible = false
				active = false
				emit_signal("sword_result", 1, Vector2())

func _process(delta):
	if active:
		cur_player_pos = DataResource.dict_player.player_pos

func _on_collectionArea_body_entered(body): # only player would be detected due to mask layer
	if state == sword_states.HIT:
		state = sword_states.HIDDEN

func _on_limitArea_body_exited(body):
	state = sword_states.RETURN
