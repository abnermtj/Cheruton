extends airState

const PULL_DOWN_STRENGTH = 0.55 # lesser than pull up as gravity contributes
const PULL_UP_STRENGTH = 1.65
const CHAIN_PULL_SPEED = 1000
const RELEASE_TIMER = .05 # time before player can zip/release rope from hands

const SWING_CONTROL_STRENGTH = .150
const SWING_GRAVITY = 135 # increasing this will indirectly increase swing speed
const SWING_SPEED = 70
const MIN_WIRE_LENGTH = 240
const MAX_WIRE_LENGTH = 600
const WIRE_REEL_SPEED = 100
const PLAYER_LENGTH_CONTROL = 300 # players influence with REEL
const REEL_LERP_FACTOR = 3.4 # factor multiplied to delta for lep

var release_timer

var chain_velocity = Vector2()
var zip_state

var prev_pos = Vector2()
var cur_pos = Vector2()
var length_rope
var desired_length_rope
var tip_pos # tip of hook/ attach point
var angle_set

func enter():
	angle_set = false
	zip_state = false

	release_timer = RELEASE_TIMER
	tip_pos = owner.tip_pos
	if owner.hook_dir == Vector2(): # if no input on enter
		owner.hook_dir = owner.look_direction

	# Integration variables
	cur_pos = owner.global_position
	prev_pos = owner.previous_position
	length_rope = (owner.global_position - tip_pos).length()
	desired_length_rope = length_rope

# Invariant : hook tip already planted
func update(delta):
	# let go of rope
	release_timer -= delta
	if Input.is_action_just_pressed("jump") and release_timer < 0: # bugs if jumping same frame as press
		if owner.is_on_ceiling():
			owner.velocity = Vector2.DOWN
		emit_signal("finished", "fall")
		return
	# zip up
	if Input.is_action_just_pressed("hook") and release_timer < 0 and owner.hooked:
		zip_state = true
	else: # note that zip up only happens in frame after press, here
		chain_velocity = (tip_pos-owner.global_position).normalized() * CHAIN_PULL_SPEED
		if chain_velocity.y > 0:
			chain_velocity.y *= PULL_DOWN_STRENGTH
		else:
			chain_velocity.y *= PULL_UP_STRENGTH
	if owner.global_position.y < tip_pos.y: # when player is above hook point
		emit_signal("finished", "fall")

	if zip_state == true:
		owner.velocity = chain_velocity
		if owner.global_position.distance_to(tip_pos) < 100:
			emit_signal("finished", "fall")
	else: # chain in air or hooked and not zipped SIMPLE PENDULUM MOtion
		_update( delta )
		_constrain( )
		_adjust()
	owner.move()
	DataResource.dict_player.player_pos = owner.global_position # main update in owner is too slow

func _update(delta):
	var input_dir = get_input_direction()
	var vel = cur_pos - prev_pos
	cur_pos = owner.global_position # previous cur pos_ no longer matched the player position due to constrains
	prev_pos = cur_pos


	cur_pos += vel + Vector2(0,(SWING_GRAVITY * delta * sin(owner.global_position.angle_to_point(tip_pos)))) + input_dir * SWING_CONTROL_STRENGTH

	desired_length_rope += input_dir.y * delta * PLAYER_LENGTH_CONTROL
	desired_length_rope = clamp(desired_length_rope, MIN_WIRE_LENGTH  , MAX_WIRE_LENGTH)
	length_rope = lerp(length_rope, desired_length_rope, delta*REEL_LERP_FACTOR)

func _constrain():
	var cur_length = (cur_pos - tip_pos).length()
	# case where player below minimum distance, don't move him too much, make it as if hes fallign to gravity
	if cur_length > length_rope or desired_length_rope > cur_length: # constrains player to a circle ceneted at hook tip
		cur_pos = (cur_pos - tip_pos).normalized() * length_rope + tip_pos


func _adjust(): # don't call move again, done in returning call
	owner.velocity = (cur_pos - prev_pos )*SWING_SPEED

func exit():
	owner.chain_release()
