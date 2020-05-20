extends airState
#NOTE some keyboards cannot detect pressing up left and space simulatenously google NKRO

const JUMP_RELEASE_SLOWDOWN = .72 #after releasing jump key how much to slow down by 0 to 1
const JUMP_GRAVITY_SLOWDOWN = .42 # slows down gravity on top of jump more drifting ability for player

var keypress_timer # timer that allaws paper to keep boosting jump height
var enter_velocity

const JUMP_VEL = -690  # jump power 670 old

func enter() -> void:
	enter_velocity = owner.velocity

	if 500 > abs(enter_velocity.x):
		enter_velocity.x = 500

	owner.has_jumped = true
	if get_parent().previous_state_name != "hook":
		owner.velocity.y = JUMP_VEL # old speed kept
	owner.move()
	owner.play_anim("jump")
	keypress_timer = 0.2

func update( delta ):
	owner.velocity.y = min( owner.TERM_VEL, owner.velocity.y + owner.GRAVITY * delta * JUMP_GRAVITY_SLOWDOWN)# use delta for all time based movements

	keypress_timer -= delta
	if keypress_timer < 0 or Input.is_action_just_released( "jump" ):
		keypress_timer = -1.0
		owner.velocity.y *= JUMP_RELEASE_SLOWDOWN

	# steering here
	var input_dir = get_input_direction()
	update_look_direction(input_dir)
	var dir = input_dir.x

	if dir: # tend to input dir if steering
		owner.velocity.x = clamp ((owner.velocity.x + dir*owner.AIR_ACCEL), -abs(enter_velocity.x), abs(enter_velocity.x))
	else: # tend .x to 0 if not steerings
		owner.velocity.x = lerp( owner.velocity.x, 0, owner.AIR_ACCEL * delta )

	owner.move()
	if owner.is_on_ceiling():
		owner.velocity.y = 0.0
		emit_signal("finished","fall")
	else:
		if owner.velocity.y > 0:
			emit_signal("finished","fall")
	.update(delta)
