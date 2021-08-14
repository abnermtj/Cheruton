extends airState

const JUMP_RELEASE_SLOWDOWN = .72 # 0 to 1, after releasing jump key how much to slow down by
const JUMP_TERMINAL_VELOCITY = 7000
const NORMAL_GRAV_MULTIPLIER = .42
const MIN_ENTER_VELOCITY_X = 420
const JUMP_VEL = -730 # 2 TILES tall -666,  2.5 -730,  3 -800
const CORNER_CORRECTION_DISPLACEMENT = 7

var enter_velocity : Vector2
var input_dir : Vector2
var keypress_timer : float # timer that allaws paper to keep boosting jump height
var grav_multiplier : float

func handle_input(event):
	if Input.is_action_just_pressed("hook"):
			if owner.can_hook:
				var nearest_hook_point = owner.nearest_hook_point
				if not nearest_hook_point:
					return

				owner.hook_dir = (nearest_hook_point.global_position - owner.global_position).normalized()

				owner.play_sound("hook_start")
#				owner.play_and_return_anim("grapple_throw")
				owner.start_hook()
	.handle_input(event)

func enter() -> void:
	grav_multiplier = NORMAL_GRAV_MULTIPLIER

	owner.velocity = owner.actual_velocity # moving platforms show a different speed with for moveslidesnap
	enter_velocity = owner.actual_velocity
	if MIN_ENTER_VELOCITY_X > abs(enter_velocity.x):
		enter_velocity.x = MIN_ENTER_VELOCITY_X

	owner.has_jumped = true
	owner.velocity.y = JUMP_VEL
	owner.play_anim("jump")
	owner.play_anim_fx("jump")
	owner.play_sound("jump" + str(randi()%7+1))
	owner.camera_state = owner.CAMERA_STATES.AIR

	if owner.bounce_boost:
		owner.velocity.y = -1600
		grav_multiplier = 1

	if owner.prev_state.name == "wallSlide": # wall jump
		owner.velocity.x = -JUMP_VEL* owner.look_direction.x * .4
		owner.global_position.x += owner.look_direction.x * 8 #so that she doesn't grab wall in edge case: jumping on a topleft corner

	keypress_timer = 0.2

func update( delta ):
	if Input.is_action_pressed("hook"):
		if owner.can_hook:
			var nearest_hook_point = owner.nearest_hook_point
			if nearest_hook_point:
				owner.hook_dir = (nearest_hook_point.global_position - owner.global_position).normalized()

				owner.play_sound("hook_start")
				owner.start_hook()
				return

	owner.velocity.y = min( JUMP_TERMINAL_VELOCITY , owner.velocity.y + owner.GRAVITY * grav_multiplier * delta)
	keypress_timer -= delta
	if keypress_timer < 0 or Input.is_action_just_released( "jump" ):
		keypress_timer = -1.0
		if not owner.bounce_boost:
			grav_multiplier = 1.5

	# steering here
	input_dir = get_input_direction()
	owner.look_direction = input_dir
	if input_dir.x: # tend to input dir if steering
		owner.velocity.x += input_dir.x*owner.AIR_ACCEL
	else: # tend .x to 0 if not steering
		owner.velocity.x = lerp( owner.velocity.x, 0,  delta * owner.AIR_ACCEL * .049)

	owner.velocity.x = clamp(owner.velocity.x, -abs(enter_velocity.x), abs(enter_velocity.x))

	# corner correction
	var corner_dir = owner.is_there_corner_above()
	if owner.velocity.y < -250:
		if corner_dir == 1: # on the right, move left
			owner.position.x -= CORNER_CORRECTION_DISPLACEMENT * (owner.velocity.y / JUMP_VEL)
		elif corner_dir == -1: #left
			owner.position.x += CORNER_CORRECTION_DISPLACEMENT * (owner.velocity.y / JUMP_VEL)

	owner.move()

	# Result of movement
	if owner.is_on_ceiling():
		owner.velocity.y = 0.0
		emit_signal("changeState","fall")
	elif owner.is_on_wall():
		owner.velocity.x *= .5

	if owner.velocity.y > 0:
		# platform boost
		if owner.is_almost_at_a_platform():
			owner.position.y -= 10
		emit_signal("changeState","fall")


	.update(delta)

func exit():
	owner.bounce_boost = false
