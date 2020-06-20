extends groundState

const MIN_VEL = 420 # should somewhat higher than min run speed (to not goto idle straight away)(in $run) before turning to run
const SLIDE_PWR = 100# 50 is normal
const SLIDE_DURATION = 1.5 # in seconds
export (Curve) var slide_curve

var initial_vel
var relative_vel
var initial_slide_anim_done : bool
var curve_timer : float

func enter():
	owner.switch_col()
	initial_vel = owner.velocity
	relative_vel = 0.01
	initial_slide_anim_done = false
	curve_timer = 0.0
	owner.play_anim("slide_begin")
	owner.queue_anim("slide_continious")
	owner.play_sound("slide")
	if initial_vel.x > 0:
		update_look_direction(Vector2.RIGHT)
	else:
		update_look_direction(Vector2.LEFT)

func _on_animation_finished(name):
	if name == "slide": initial_slide_anim_done = true

func update(delta):
	# player needs to move a certain time before can slide back up
	if ((not Input.is_action_pressed("slide")\
	 and (abs(owner.velocity.x) < abs(initial_vel.x)/2 or initial_vel.x < MIN_VEL)\
	 and abs(owner.velocity.x) < MIN_VEL)) \
	 and not owner.exit_slide_blocked:
		emit_signal("finished", "run")
		return

	if initial_slide_anim_done:
		if owner.velocity.x > 300:
			owner.play_anim("slide_continious_fast")
		else:
			owner.play_anim("slide_continious")

	curve_timer = clamp(curve_timer + delta/SLIDE_DURATION,0 , 1)
	relative_vel = slide_curve.interpolate(curve_timer)
	owner.velocity = initial_vel * (1-relative_vel) + Vector2(0,10)

	owner.move()

	owner.volume("slide", clamp(abs(owner.velocity.x/80)-30, -30 , 0)) # volume proportional to speed
	.update(delta)

func exit():
	owner.play_anim("slide_recover")
	owner.switch_col()
