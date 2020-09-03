extends airState

const RELEASE_TIMER = .05 # time before player can release rope from hands

const SWING_CONTROL_STRENGTH = .11
const SWING_GRAVITY = 110 # increasing this will indirectly increase swing speed
const SWING_SPEED = 60 # 70 for funzz 56.5 for the realz
const MIN_WIRE_LENGTH = 150
const MAX_WIRE_LENGTH = 1200
const PLAYER_LENGTH_CONTROL = 250	# player's influence with REEL, too much may may make movements not smooth at the end
const REEL_LERP_FACTOR = 2.45 # factor multiplied to delta for lerp
const TOP_SPEED = 1600

var release_timer : float

var hit_ceil = false
var hit_wall = false
var close_to_floor = false

var cur_pos = Vector2()
var next_pos = Vector2()
var tip_pos : Vector2 # tip of hook/ attach point
var length_rope = 0.0
var desired_length_rope = 0.0

var initial_swing_anim_done = false

func enter():
	release_timer = RELEASE_TIMER
	tip_pos = owner.tip_pos

	owner.set_collision_mask_bit(0, false) # to not collidewith random props
	# Integration variables
	next_pos = owner.global_position
	cur_pos = owner.global_position - owner.velocity *.0146
	length_rope = (owner.global_position - tip_pos).length()
	desired_length_rope = length_rope * .977

	owner.play_anim("swing_begin")
	owner.queue_anim("swing_continious6")
	owner.play_sound("hook_hit")
	owner.camera_state = owner.CAMERA_STATES.HOOK
	initial_swing_anim_done = false

func _on_animation_finished(anim_name):
	if anim_name == "swing_begin":
		initial_swing_anim_done = true

# Invariant : hook tip already planted
func update(delta):
	release_timer -= delta
	if  not Input.is_action_pressed("hook") or Input.is_action_just_pressed("jump") and release_timer < 0:
		owner.chain_release()
		emit_signal("changeState", "fall")
		return

	_update( delta )
	_constrain( )
	_adjust()
	owner.move()

	if owner.get_close_to_floor_collider():
		close_to_floor = true
	if owner.is_on_floor():
		emit_signal("changeState", "run")
	if owner.is_on_ceiling():
		hit_ceil = true
	if owner.is_on_wall():
		hit_wall = true

func update_idle(delta):
	var angle_deg = rad2deg(owner.global_position.angle_to_point(tip_pos) - PI/2)

	var cur_body_rot_deg = owner.body_pivot.rotation_degrees

	var angular_dist = angle_deg - cur_body_rot_deg
	# the way angles work in the game engines mean there is a huge jump from 0 to -180, whhhih causes the player to rotate 360
	if abs(angular_dist) >= 180:
		cur_body_rot_deg += 360 * sign(angular_dist)  # else will do 360's
		owner.body_pivot.rotation_degrees  += 360 * sign(angular_dist)

	owner.body_pivot.rotation_degrees = lerp (cur_body_rot_deg, angle_deg, delta * 16)
	if initial_swing_anim_done:
		var flip_swing_frame_order = int (owner.look_direction.x == 1)

		var swing_frame_number = int(clamp(angle_deg/7.5 + 5, 0, 12))
		if flip_swing_frame_order: swing_frame_number = 12 - swing_frame_number

		var swing_frame = "swing_continious" + str(swing_frame_number)
		owner.play_anim(swing_frame)

func _update(delta):
	var input_dir = get_input_direction()
	var vel = next_pos - cur_pos # uses previous values to calculate current

	cur_pos = owner.global_position # as next_pos no longer matched the player position due to constrains
	next_pos = cur_pos

	if not (hit_ceil or hit_wall or close_to_floor) :#and cur_pos.y > tip_pos.y :  # player control if no collision
		desired_length_rope += input_dir.y * delta * PLAYER_LENGTH_CONTROL
	desired_length_rope = clamp(desired_length_rope, MIN_WIRE_LENGTH, MAX_WIRE_LENGTH)

	if hit_ceil:
		vel.y = 0
		hit_ceil = false
	if hit_wall:
		vel.x = 0
		hit_wall = false
	if close_to_floor:
		close_to_floor = false
		desired_length_rope -= 8
		owner.global_position.y -= 2

	var adjusted_swing_control_strength = SWING_CONTROL_STRENGTH + max(0, .15 + (-0.000000213 * vel.x * vel.x)  + (0.000320 * vel.x))

	length_rope = (owner.global_position - tip_pos).length()

	if length_rope >= desired_length_rope:
		if owner.global_position.y > tip_pos.y+50:
			next_pos += vel + Vector2(0,(SWING_GRAVITY * delta * sin(owner.global_position.angle_to_point(tip_pos)))) + input_dir * adjusted_swing_control_strength
		else:
			next_pos += vel + Vector2(0,SWING_GRAVITY*delta*.4) + input_dir * adjusted_swing_control_strength # physics is wrong but high gravity needed for the speed up
	else:
		next_pos += vel + Vector2 (0, SWING_GRAVITY * delta * .5)

	length_rope = lerp(length_rope, desired_length_rope, delta*REEL_LERP_FACTOR)

func _constrain():
	var next_length = (next_pos - tip_pos).length()
	if next_length > length_rope :#or desired_length_rope > next_length: # constrains player to a circle ceneted at hook tip
		next_pos = (next_pos - tip_pos).normalized() * length_rope + tip_pos

	if desired_length_rope > length_rope:
		desired_length_rope = length_rope

func _adjust():
	owner.velocity = (next_pos - cur_pos )*SWING_SPEED
	owner.velocity.x = clamp (owner.velocity.x, -TOP_SPEED, TOP_SPEED)
	owner.velocity.y = clamp (owner.velocity.y, -TOP_SPEED, TOP_SPEED)

func exit():
	owner.body_pivot.rotation =  0
	owner.set_collision_mask_bit(0, true)

	owner.play_anim("swing_exit")
