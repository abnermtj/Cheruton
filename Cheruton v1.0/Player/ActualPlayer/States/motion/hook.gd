extends motionState

const PLAYER_ENTER_SLOWDOWN  = 1 # delete if don't need to slow player when entering hook state
const PULL_DOWN_STRENGTH = 0.55 # lesser than pull up as gravity contributes
const PULL_UP_STRENGTH = 1.65
const CHAIN_PULL_SPEED = 1000
const RELEASE_TIMER = .100 # time before player can zip/release rope from hands

const SWING_CONTROL_STRENGTH = .150
const SWING_GRAVITY = 150 # increasing this will indirectly increase swing speed
const SWING_SPEED = 90
var release_timer

var chain_velocity = Vector2()
var zip_state

var prev_pos = Vector2()
var cur_pos = Vector2()
var length_rope

var tip_pos # tip of hook/ attach point
var angle_set


func enter():
	angle_set = false
	zip_state = false

	release_timer = RELEASE_TIMER
	tip_pos = owner.tip_pos
	if owner.hook_dir == Vector2(): # if no input on enter
		owner.hook_dir = owner.look_direction

	# Enter Slowdown
	owner.velocity *= PLAYER_ENTER_SLOWDOWN

	# Integration variables
	cur_pos = owner.global_position
	prev_pos = owner.previous_position
	length_rope = (owner.global_position - tip_pos).length()

# Invariant : hook tip already planted
func update(delta):
	# let go of rope
	release_timer -= delta
	if Input.is_action_just_pressed("jump") and release_timer < 0: # bugs if jumping same frame as press
		if owner.is_on_ceiling():
			owner.velocity = Vector2.DOWN
		emit_signal("finished", "previous")
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

	if zip_state == true:
		owner.velocity = chain_velocity
	else: # chain in air or hooked and not zipped
		# Verlet integration
		_update( delta )
		_constrain( )
		_adjust()
	owner.move()
	DataResource.dict_player.player_pos = owner.global_position # main update in owner is too slow

func _update(delta):
	var shift = cur_pos - prev_pos
	cur_pos = owner.global_position # previous cur pos_ no longer matched the player position due to constrains
	prev_pos = cur_pos
	cur_pos += shift + get_input_direction() * SWING_CONTROL_STRENGTH
	cur_pos.y += SWING_GRAVITY * delta
	length_rope = clamp(length_rope*.995, 300 , INF)

func _constrain():
	if (cur_pos - tip_pos).length() > length_rope: # constrains player to a circle ceneted at hook tip
		cur_pos = (cur_pos - tip_pos).normalized() * length_rope + tip_pos

func _adjust(): # don't call move again, done in returning call
	owner.velocity = (cur_pos - prev_pos )*SWING_SPEED


func exit():
	owner.chain_release()
