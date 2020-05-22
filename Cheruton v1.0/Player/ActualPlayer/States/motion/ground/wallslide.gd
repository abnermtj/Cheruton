extends groundState

const GRAVITY_STRENGTH_MIN = 0.009
const GRAVITY_STRENGTH_MAX = 0.03
const SPEED_UP_FACTOR = .01
const FAST_SLIDE_ACCEL = 10
const FAST_SLIDE_MAX_SPEED_INCREASE = 100
var gravity_strength = .02
var slide_down : bool

func enter():
	owner.play_anim("wall_slide")
	var gravity_strength = GRAVITY_STRENGTH_MIN
	update_look_direction(Vector2(-owner.wall_direction,0))

func update(delta):

	if not owner._update_wall_direction(): # no wall to slide onto
		emit_signal("finished", "fall")

	var input_dir = get_input_direction()
	slide_down = input_dir.y == 1

	gravity_strength = lerp(gravity_strength, GRAVITY_STRENGTH_MAX, delta*SPEED_UP_FACTOR)
	owner.velocity.x = 0
	owner.velocity.y = lerp( owner.velocity.y, (owner.GRAVITY*gravity_strength)+int(slide_down)*FAST_SLIDE_MAX_SPEED_INCREASE, delta*8) +int(slide_down)*FAST_SLIDE_ACCEL
	owner.move()
