extends groundState

const GRAVITY_STRENGTH_MIN = 0.0009
const GRAVITY_STRENGTH_MAX = 0.03
const SPEED_UP_FACTOR = .01
const FAST_SLIDE_ACCEL = 10
const FAST_SLIDE_MAX_SPEED_INCREASE = 450
const SLIDE_DOWN_LERP_FACTOR = 8
const GRIP_TIME = 3 # how long character can stay still

var gravity_strength = .02
var slide_down : bool
var grip_timer

func enter():
	owner.play_anim("wall_slide")
	gravity_strength = GRAVITY_STRENGTH_MIN
	update_look_direction(Vector2(-owner.wall_direction,0))
	owner.can_attack = false
	grip_timer = GRIP_TIME

	if owner.jump_again:
		emit_signal("finished", "jump")

func update(delta):
	grip_timer -= delta
	if owner.velocity.y > 75:
		owner.play_anim("wall_slide_fast")
	else:
		owner.play_anim("wall_slide")

	if not owner._update_wall_direction(): # no wall to slide onto
		emit_signal("finished", "fall")

	var input_dir = get_input_direction()
	slide_down = input_dir.y == 1 or grip_timer < 0

	gravity_strength = lerp(gravity_strength, GRAVITY_STRENGTH_MAX, delta*SPEED_UP_FACTOR)
	owner.velocity.x = owner.wall_direction * 200 # this move player to stick to wall
	owner.velocity.y = lerp( owner.velocity.y, (owner.GRAVITY*gravity_strength)+int(slide_down)*FAST_SLIDE_MAX_SPEED_INCREASE, delta*SLIDE_DOWN_LERP_FACTOR) +int(slide_down)*FAST_SLIDE_ACCEL
	owner.move()

	if owner.is_on_floor():
		emit_signal("finished", "idle")

func exit():
	owner.can_attack = true
