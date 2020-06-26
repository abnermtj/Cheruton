extends baseState

const SPEED = 465  # faster than player
const RUN_SPEED = 100

const LEG_DIST_MARGIN = 460

var leg_move_timer
var desired_velocity = Vector2()

func enter():
	leg_move_timer = owner.LEG_MOVE_COOLDOWN

func update(delta):
	var next_position =  0.9*((owner.get_parent().get_node("player")).global_position ) + Vector2(0, -200) # the offset account for the spider never touching the player due to hitbox
#	next_position = owner.get_global_mouse_position()

	if owner.ground_check.is_colliding() and owner.velocity.length() > SPEED/3:
		next_position.y -= owner.ground_check.get_collision_point().y - owner.global_position.y + 10 # const makes it bob less jittery

	desired_velocity =  next_position - owner.global_position

	if desired_velocity.length() > SPEED:
		desired_velocity = desired_velocity.normalized() * SPEED

	owner.velocity = lerp(owner.velocity, desired_velocity, 2 * delta)

	owner.velocity = owner.move()
	owner.move_body_sprites()
	if owner.player_in_small_look_area:
		emit_signal("finished","stepBack")

func update_idle(delta):
	leg_move_timer -= delta
	if leg_move_timer > 0 : return

	var max_leg_dist_from_desired = 0

	for leg in owner.a_legs:
		max_leg_dist_from_desired = owner.check_most_displaced_leg(leg, true, max_leg_dist_from_desired)
	for leg in owner.b_legs:
		max_leg_dist_from_desired = owner.check_most_displaced_leg(leg, false, max_leg_dist_from_desired)

	if owner.flip_legs:
		for leg in owner.a_legs:
			if leg.is_step_over(): move_leg(leg)
		leg_move_timer = owner.LEG_MOVE_COOLDOWN
	else:
		for leg in owner.b_legs:
			if leg.is_step_over(): move_leg(leg)
		leg_move_timer = owner.LEG_MOVE_COOLDOWN

func move_leg(leg):
	# moves ray to adjust for different velocities
	var desired_pos = leg.get_collision_point()
	if not desired_pos: return

	var adjusted_leg_dist_margin = LEG_DIST_MARGIN * clamp (abs(owner.velocity.x) /SPEED, .4, 2) - (100 if owner.ground_check.is_colliding() else 0 )# closer to ground movement made legs reach full extention easily

	var tip_pos = leg.get_tip_pos()
	owner.next_pos_col_check.global_position = tip_pos + Vector2(0 , -50) # else it would touch the floor during walks
	owner.next_pos_col_check.cast_to = desired_pos - tip_pos + Vector2(0, -50)
	var way_to_next_step_has_collision = true if owner.next_pos_col_check.is_colliding() else false# quickly places foot before collision collision peirces through the leg, making it look unrealistic
	if leg.get_tip_dist_to_point(desired_pos) > adjusted_leg_dist_margin or way_to_next_step_has_collision:
		leg.step(desired_pos)

func exit():
	pass
