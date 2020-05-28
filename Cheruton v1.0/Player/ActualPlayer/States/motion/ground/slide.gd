extends groundState

const MIN_VEL = 100 # should somewhat higher than min run speed (to not goto idle straight away)(in $run) before turning to run
const SLIDE_PWR = 300 # 50 is normal
export (Curve) var attachment_curve

var initial_vel
var relative_vel
# Animation Player handles collsion
func enter():
	owner.switch_col()
	initial_vel = owner.velocity
	relative_vel = 0.01
	owner.play_anim("slide")
	owner.queue_anim("slide_continious")
	owner.play_sound("slide")

	if initial_vel.x > 0:
		update_look_direction(Vector2.RIGHT)
	else:
		update_look_direction(Vector2.LEFT)


func update(delta):
	relative_vel = attachment_curve.interpolate(relative_vel)
	owner.velocity = initial_vel * (1-relative_vel) + SLIDE_PWR*Vector2(get_input_direction().x,0) + Vector2(0,10)

	if owner.velocity.x > 300:
		owner.play_anim("slide_continious_fast")
	else:
		owner.play_anim("slide_continious")

	# player needss to move a certain time before can slide back up
	if ((not Input.is_action_pressed("slide") and abs(owner.velocity.x) < abs(initial_vel.x)/2 or abs(owner.velocity.x) < MIN_VEL)) \
	 and not owner.exit_slide_blocked:
		emit_signal("finished", "run")
		return
	owner.move()
	owner.volume("slide", clamp(abs(owner.velocity.x/80)-30, -30 , 0))
	.update(delta)

func exit():
	owner.play_anim("slide_recover")
	owner.switch_col()
