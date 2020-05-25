extends airState

#const CHAIN_PULL_SPEED = 950
const RELEASE_TIMER = .05 # time before player can zip/release rope from hands

const SWING_CONTROL_STRENGTH = .045
const SWING_GRAVITY = 71.5 # increasing this will indirectly increase swing speed
const SWING_SPEED = 61.5
const MIN_WIRE_LENGTH = 40
var MAX_WIRE_LENGTH = 300 #
var PLAYER_LENGTH_CONTROL = 100 # players influence with REEL, too much may may make movements not smooth at the end
const REEL_LERP_FACTOR = .7 # factor multiplied to delta for lep
const TOP_SPEED = 1000
const APPROACHING_GROUND_REEL = 30

var release_timer

#var zip_state
var hit_ceil = false
var hit_wall = false
var close_to_floor = false

var cur_pos = Vector2()
var next_pos = Vector2()
var length_rope = 0.0
var desired_length_rope = 0.0
var tip_pos # tip of hook/ attach point

func enter():
#	zip_state = false
	release_timer = RELEASE_TIMER
	tip_pos = owner.tip_pos
	if owner.hook_dir == Vector2(): # if no input on enter
		owner.hook_dir = owner.look_direction

	# Integration variables
	next_pos = owner.global_position
	cur_pos = owner.previous_position
	length_rope = (owner.global_position - tip_pos).length()
	MAX_WIRE_LENGTH = length_rope * 1.1
	desired_length_rope = length_rope *.9 # make it hard for player to touch ground

	owner.arm_rotate.visible = true
	owner.play_anim("swing")
	owner.play_sound("hook_hit")

# Invariant : hook tip already planted
func update(delta):
	if owner.is_on_ceiling():
		hit_ceil = true
	if owner.is_on_wall():
		hit_wall = true
	if owner.is_on_floor():
		emit_signal("finished", "run")
	if owner.close_to_floor():
		close_to_floor = true

	release_timer -= delta
	if Input.is_action_just_pressed("jump") and release_timer < 0:
		release_hook()
		return
	# zip up
#	if Input.is_action_just_pressed("hook") and release_timer < 0 and owner.hooked:
#		zip_state = true

	if owner.global_position.y < tip_pos.y: # release when player above hook point
		release_hook()
		return

#	if zip_state == true:
#		owner.velocity = (tip_pos-owner.global_position).normalized() * CHAIN_PULL_SPEED
#		if owner.global_position.distance_to(tip_pos) < 100:
#			release_hook()
#			return
#	else:
	# chain in air or hooked and not zipped SIMPLE PENDULUM MOtion
	_update( delta )
	_constrain( )
	_adjust()
	owner.move()

	DataResource.dict_player.player_pos = owner.global_position # main update in owner is too slow rope lags

func update_idle(delta):
	owner.get_node("bodyPivot").rotation =  owner.global_position.angle_to_point(tip_pos) - PI/2

# INTEGRATION
func _update(delta):
	var input_dir = get_input_direction()
	var vel = next_pos - cur_pos # uses previous values to calculate current

	cur_pos = owner.global_position # as next_pos no longer matched the player position due to constrains
	next_pos = cur_pos

	PLAYER_LENGTH_CONTROL  = 200 if vel.length() < 100 else 50 # player has more control of the length if still
	if not (hit_ceil or hit_wall or close_to_floor) and length_rope <= MAX_WIRE_LENGTH + 15:  # player control if no collision
		desired_length_rope += input_dir.y * delta * PLAYER_LENGTH_CONTROL

	if hit_ceil:
		vel.y = 0
		hit_ceil = false
	if hit_wall:
		vel.x = 0
		hit_wall = false
	if close_to_floor:
		close_to_floor = false
		desired_length_rope -= 50- owner.vec_to_ground.y

	next_pos += vel + Vector2(0,(SWING_GRAVITY * delta * sin(owner.global_position.angle_to_point(tip_pos)))) + input_dir * SWING_CONTROL_STRENGTH
	desired_length_rope = clamp(desired_length_rope, MIN_WIRE_LENGTH, MAX_WIRE_LENGTH)

	length_rope = lerp(length_rope, desired_length_rope, delta*REEL_LERP_FACTOR)

func _constrain():
	var next_length = (next_pos - tip_pos).length()
	if next_length > length_rope or desired_length_rope > next_length: # constrains player to a circle ceneted at hook tip
		next_pos = (next_pos - tip_pos).normalized() * length_rope + tip_pos

func _adjust():
	owner.velocity = (next_pos - cur_pos )*SWING_SPEED
	owner.velocity.x = clamp (owner.velocity.x, -TOP_SPEED, TOP_SPEED)
	owner.velocity.y = clamp (owner.velocity.y, -TOP_SPEED, TOP_SPEED)

func release_hook():
	owner.chain_release()
	emit_signal("finished", "fall")

func exit():
	owner.get_node("bodyPivot").rotation =  0
	owner.arm_rotate.visible = false
