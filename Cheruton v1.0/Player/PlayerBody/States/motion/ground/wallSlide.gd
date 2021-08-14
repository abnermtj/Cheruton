extends groundState

const GRAVITY_STRENGTH_MIN = 0.0009
const GRAVITY_STRENGTH_MAX = 1
const TERM_VEL = 1000
const GRIP_TIME = 2.5 # how long character can stay still

var gravity_strength = .02
var slide_down : bool
var grip_timer : float
var input_dir : Vector2
var prev_sword_state

func enter():
	owner.can_attack = true # else not touching ground will permanently disable  attack
	owner.attack_count = 0
	if owner.jump_again:
		emit_signal("changeState", "jump")
		return

	gravity_strength = GRAVITY_STRENGTH_MIN
	grip_timer = GRIP_TIME
	owner.play_anim("wall_slide")
	owner.play_sound("wall_slide")
	
	if (owner.velocity.length() > 800):
		owner.play_sound("wall_slide_fast")


func update(delta):
	var wall_dir = owner.get_wall_direction()
	if not wall_dir: # no wall to slide onto
		emit_signal("changeState", "fall")
		return

	owner.look_direction = Vector2(-wall_dir, 0)
	if owner.velocity.y > 75:
		owner.play_anim("wall_slide_fast")
	else:
		owner.play_anim("wall_slide")

	grip_timer -= delta
	var slide_down = (get_input_direction().y == 1) or grip_timer < 0

	if slide_down:
		gravity_strength = lerp(gravity_strength, GRAVITY_STRENGTH_MAX, delta )
		owner.velocity.y += gravity_strength * owner.GRAVITY * delta
	else:
		owner.velocity.y = lerp(owner.velocity.y, 0, delta * 4.5)
	owner.velocity.y = clamp(owner.velocity.y, -INF, TERM_VEL)

	owner.velocity.x = owner.wall_direction * 200 # this move player to stick to wall

	owner.move()

	if owner.is_on_floor():
		emit_signal("changeState", "idle")
