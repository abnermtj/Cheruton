extends groundState

const MIN_VEL = 420 # should somewhat higher than min run speed (to not goto idle straight away)(in $run) before turning to run
const SLIDE_PWR = 100# 50 is normal
const SLIDE_DURATION = 1.5 # in seconds
export (Curve) var attachment_curve

var initial_vel
var relative_vel
var initial_slide_anim_done : bool
var input_dir
var curve_timer : float
# Animation Player handles collsion
func enter():
	owner.switch_col()
	initial_vel = owner.velocity
	relative_vel = 0.01
	initial_slide_anim_done = false
	curve_timer = 0.0
	owner.play_anim("slide")
	owner.queue_anim("slide_continious")
	owner.play_sound("slide")
	if initial_vel.x > 0:
		update_look_direction(Vector2.RIGHT)
	else:
		update_look_direction(Vector2.LEFT)

func _on_animation_finished(name):
	if name == "slide":	initial_slide_anim_done = true

func update(delta):
	curve_timer = clamp(curve_timer + delta/SLIDE_DURATION,0 , 1)
	relative_vel = attachment_curve.interpolate(curve_timer)
	input_dir = get_input_direction()
	owner.velocity = initial_vel * (1-relative_vel) + Vector2(0,10)

	if abs(owner.velocity.x) < SLIDE_PWR: # don't want a stationary character during slide
		owner.velocity.x = SLIDE_PWR * owner.look_direction.x

	if initial_slide_anim_done:
		if owner.velocity.x > 300:
			owner.play_anim("slide_continious_fast") # need to queue else initial anim cut off
		else:
			owner.play_anim("slide_continious")

	# player needss to move a certain time before can slide back up
	if ((not Input.is_action_pressed("slide")\
	 and (abs(owner.velocity.x) < abs(initial_vel.x)/2 or initial_vel.x < MIN_VEL)\
	 and abs(owner.velocity.x) < MIN_VEL)) \
	 and not owner.exit_slide_blocked:
		emit_signal("finished", "run")
		return
	owner.move()
	owner.volume("slide", clamp(abs(owner.velocity.x/80)-30, -30 , 0))
	.update(delta)

func exit():
	owner.play_anim("slide_recover")
	owner.switch_col()
