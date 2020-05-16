extends motionState
#NOTE some keyboards cannot detect pressing up left and space simulatenously google NKRO

const JUMP_RELEASE_SLOWDOWN = .72 #after releasing jump key how much to slow down by 0 to 1
const JUMP_GRAVITY_SLOWDOWN = .42 # slows down gravity on top of jump more drifting ability for player

var keypress_timer # timer that allaws paper to keep boosting jump height

const JUMP_VEL = -670.0  # jump power 670 old

func enter() -> void:
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
		owner.velocity.x = lerp( owner.velocity.x, owner.MAX_VEL * dir, owner.AIR_ACCEL * delta ) # moves towards goal velocity LERP isn't good
	else: # tend .x to 0 if not steerings
		owner.velocity.x = lerp( owner.velocity.x, 0, owner.AIR_ACCEL * delta )

	owner.move()

	if owner.is_on_ceiling():
		owner.velocity.y = 0.0
		emit_signal("finished","fall")
	else:
		if owner.velocity.y > 0:
			emit_signal("finished","fall")
