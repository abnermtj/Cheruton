extends airState

const JUMP_AGAIN_MARGIN = 0.12 # seconds need to press jump this amout of time for it to input buffer
const COYOTE_TIME = 0.08 # time after leaving edge before you are not allowed to jump
const TERM_VEL = 3000

var coyote_timer : float # here incase playeer walks off an edge
var jump_timer : float
var jump_again : bool # jump keypress bufered
var enter_velocity

var slide_timer : float
var slide :bool

func enter():
	enter_velocity = owner.velocity
	if 500 > abs(enter_velocity.x):
		enter_velocity.x = 500

	owner.play_anim("hover")
	owner.queue_anim("fall")
	coyote_timer = COYOTE_TIME
	jump_again = false
	slide = false

func update(delta):
	coyote_timer -= delta
	jump_timer -= delta

	owner.velocity.y = min( TERM_VEL, owner.velocity.y + owner.GRAVITY * delta ) # dunnid delta here by right, move and slide deals with it

	var input_dir = get_input_direction()
	update_look_direction(input_dir)
	var dir = input_dir.x

	if dir:
		owner.velocity.x = clamp ((owner.velocity.x + dir*owner.AIR_ACCEL), -abs(enter_velocity.x), abs(enter_velocity.x))
	else:
		owner.velocity.x = lerp( owner.velocity.x, 0, delta )

	owner.move_and_slide(owner.velocity, Vector2.UP)

	# jump input buffering
	if Input.is_action_just_pressed( "jump" ):
		jump_timer = JUMP_AGAIN_MARGIN
		jump_again = true
		if coyote_timer > 0 and not owner.has_jumped:  # when accidentally falling off edges
				emit_signal("finished", "jump")
				return
	# slide input buffering
	if Input.is_action_just_pressed( "slide" ):
		slide_timer = JUMP_AGAIN_MARGIN # reuse should be consistent
		slide = true

	# wall crash
	if owner.is_on_wall():
		owner.velocity.x = 0
	if owner.is_on_ceiling():
			owner.velocity.y = 0
	# landing
	if owner.is_on_floor():
		owner.has_jumped = false
		owner.play_anim_fx("land")
		if (jump_again and jump_timer >= 0):
			emit_signal("finished", "jump")
		elif (slide and slide_timer >= 0):
			emit_signal("finished", "slide")
		else:
			# land
			owner.play_sound("land")
			emit_signal("finished", "run")

	# bouncepad
	var col
	if owner.get_slide_count():
		col = owner.get_slide_collision(0).get_collider()
		if col.is_in_group("bouncePads"):
			owner.bounce_boost = true
			emit_signal("finished", "jump")

	.update(delta)
