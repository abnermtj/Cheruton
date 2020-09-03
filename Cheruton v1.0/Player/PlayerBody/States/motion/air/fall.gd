extends airState

const COYOTE_TIME = 0.085 # time window after leaving edge where you are allowed to jump
const TERM_VEL = 1200
const MIN_ENTER_VELOCITY_X = 420 # same as run

var coyote_timer : float # here incase playeer walks off an edge
var enter_velocity

func handle_input(event):
	if Input.is_action_just_pressed("jump"):
		owner.jump_buffer_start() # used for input buffering
		if coyote_timer > 0 and not owner.has_jumped:
				emit_signal("changeState", "jump")

	.handle_input(event)

func enter():
	enter_velocity = owner.velocity

	if owner.hooked:
		emit_signal("changeState", "hook")
		return
	if MIN_ENTER_VELOCITY_X > abs(enter_velocity.x):
		enter_velocity.x = MIN_ENTER_VELOCITY_X

	if owner.prev_state.name == "hook":
		 owner.queue_anim("fall")
	elif owner.velocity.y < 50:
		owner.play_anim("hover")
		owner.queue_anim("fall")
	else:
		owner.play_anim("fall")

	coyote_timer = COYOTE_TIME

func update(delta):
	if Input.is_action_pressed("hook"):
		if owner.can_hook:
			var nearest_hook_point = owner.nearest_hook_point
			if nearest_hook_point:
				owner.hook_dir = (nearest_hook_point.global_position - owner.global_position).normalized()

				owner.play_sound("hook_start")
				owner.start_hook()
				return

	coyote_timer -= delta

	owner.velocity.y = min(TERM_VEL, owner.velocity.y + owner.GRAVITY * delta) # dunnid delta here by right, move and slide deals with it

	# Air steering
	var input_dir = get_input_direction()
	owner.look_direction = input_dir

	if input_dir.x:
		owner.velocity.x = clamp ((owner.velocity.x + input_dir.x*owner.AIR_ACCEL), -abs(enter_velocity.x), abs(enter_velocity.x))
	else:
		owner.velocity.x = lerp(owner.velocity.x, 0, delta)

	# wall crash
	if owner.is_on_wall():
		owner.velocity.x *= .5

	if owner.is_on_ceiling():
		owner.velocity.y = 1 # cannot 0 else is on_celing bug
	# landing
	if owner.is_on_floor():
		owner.has_jumped = false
		owner.play_anim_fx("land")

		owner.camera_state = owner.CAMERA_STATES.GROUND
		if owner.velocity.y > 850:
			owner.emit_dust("land")

		var col = owner.get_slide_collision(0).get_collider() # bounce pad
		if col and  col.is_in_group("bouncePads"):
			owner.bounce_boost = true
			emit_signal("changeState", "jump")
			return

		if owner.jump_again:
			emit_signal("changeState", "jump")
		elif Input.is_action_pressed("slide"):
			emit_signal("changeState", "slide")
		else:
			owner.play_sound("land")
			emit_signal("changeState", "run")

	owner.move()
	.update(delta)
