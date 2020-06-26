extends Position2D

const MIN_LENGTH = 260 # used so it doesn't dissapear 118 min for sss 330 for fabrik
const DEFAULT_STEP_RATE = 0.4 # actual time in seconds taken to complete a step
const STEP_HEIGHT = 55

enum legs {UPPER_LEG = 0, MIDDLE_LEG = 1, LOWER_LEG = 2}

onready var joint1 = $joint1
onready var joint2 = $joint1/joint2
onready var tip = $joint1/joint2/tip

var length_upper = 0
var length_middle = 0
var length_lower = 0

export var flipped = true

var tip_pos : Vector2
var start_pos = Vector2()
var middle_pos = Vector2()
var cur_target_pos = Vector2()
var step_time = 0.0
var is_step_over = false
var total_rotation = 0.0
var step_rate = DEFAULT_STEP_RATE
var hold = false # used to hold to maintain relative distance to parent
var relative_position : Vector2

func _ready():
	length_upper = joint1.position.x
	length_middle = joint2.position.x
	length_lower = tip.position.x
	if flipped:
		$Sprite.flip_h = true
		joint1.get_node("Sprite").flip_h = true
		joint2.get_node("Sprite").flip_h = true

func step(target_pos):
	hold = false

	randomize() # makes it more natural my varying step rate
	step_rate = DEFAULT_STEP_RATE + clamp(rand_range(0,1000)/1000 * .08 ,-.08,.08)
	if target_pos == cur_target_pos: return

	is_step_over = false

	cur_target_pos = target_pos
	start_pos =  tip.global_position
	tip_pos = tip.global_position

	step_rate += clamp( (tip_pos.distance_to(target_pos) - 1000)/ 1000, 0 , 0.2) # longer steps when mocing greater distances

	var highest_y = min (target_pos.y, tip_pos.y)

	var mid_x = (target_pos.x + tip_pos.x)/ 2.0
	middle_pos = Vector2(mid_x, highest_y - STEP_HEIGHT)
	step_time = 0.0

func timed_step(target_pos, time):
	step(target_pos)
	step_rate = time
func step_and_hold(pos, time):
	step(pos)

	step_rate = time
	hold = true # NOTE needs to after step()
	relative_position = pos - get_parent().global_position

func _process(delta):
	step_time += delta
	var target_pos = Vector2()
	var step_percent = step_time / step_rate # percentage of the step completed

	if hold: cur_target_pos = get_parent().global_position + relative_position

	if step_percent < .5:
		target_pos = start_pos.linear_interpolate(middle_pos, step_percent * 2)
	elif step_percent < 1.0:
		target_pos = middle_pos.linear_interpolate(cur_target_pos, (step_percent-.5) * 2)
	else:
		target_pos = cur_target_pos
		is_step_over = true
		tip_pos = target_pos

#	target_pos = get_viewport().get_mouse_position()
#	print(target_pos-global_position)
	update_ik(target_pos)

	total_rotation = joint1.rotation_degrees + joint2.rotation_degrees

# SSS IMPLMENTATION################################
func update_ik(target_pos):
	var offset = target_pos - global_position #from shoulder to foot
	var dist_to_target = offset.length()
	if dist_to_target < MIN_LENGTH:
		offset = offset / dist_to_target * MIN_LENGTH
		dist_to_target = MIN_LENGTH

	var base_r = offset.angle() # used to make the bottom triangle in the diagram flat on the floor
	var length_total = length_lower + length_middle + length_upper
	var length_dummy_side = (length_upper + length_middle) * clamp(dist_to_target / length_total, 0.0, 1.0)

	var base_angles = angles_of_triangle(length_dummy_side, length_lower, dist_to_target)
	var next_angles = angles_of_triangle(length_upper, length_middle, length_dummy_side)

	global_rotation = base_angles.B + next_angles.B + base_r
	joint1.rotation = next_angles.C
	joint2.rotation = base_angles.C + next_angles.A

func angles_of_triangle(side_a, side_b, side_c):
	if side_c >= side_a + side_b:
		return {"A": 0, "B": 0, "C": 0} # happens when the sprite stretchs out

	var angle_a = law_of_cos(side_b, side_c, side_a)
	var angle_b = law_of_cos(side_c, side_a, side_b) + PI
	var angle_c = PI - angle_a - angle_b

	if flipped:
		angle_a = -angle_a
		angle_b = -angle_b
		angle_c = -angle_c

	return {"A": angle_a, "B": angle_b, "C": angle_c}

# returns an angle in radians of a angle in a triangle
func law_of_cos(a, b, c):
	if a * b == 0:
		return 0
	return acos( (a * a + b * b - c * c) / ( 2 * a * b) )

func get_dist_tip_to_point(point: Vector2):
	return (tip.global_position - point).length()

func set_tip_hurt_box_disabled(val):
	tip.get_node("Area2D/CollisionShape2D").disabled = val
# FABRIK IMPLMENTATION TEST

# used for FABRIK
#const INWARD_FOLD_ANGLE_LIMIT = 25 # represents the angles in which the leg cannot fold into
#const MIN_DIST_MARGIN = 1
#
#var leg_origin_pos : Vector2
#var leg_pos_dict = {}
#var leg_length_dict = {}
#func update_ik(target_pos):
#	var vec_to_target = target_pos - global_position
#	var dist_to_target = vec_to_target.length()
#
#	# Skips calculations if already out of range
#	if dist_to_target > (length_lower + length_middle + length_upper):
#		global_rotation = global_position.angle_to_point(target_pos) - PI
#		joint1.rotation = -.01 if flipped else .01
#		joint2.rotation = .01 if flipped else -.01
#		return
#
#	# So that the leg doesnt fold over into itself if too close
#	if dist_to_target< MIN_LENGTH:
#		target_pos = global_position + MIN_LENGTH * vec_to_target.normalized()
#
#	var end_effector_pos = tip.global_position
#	leg_origin_pos = global_position
#
#	leg_pos_dict = {legs.UPPER_LEG : [global_position, joint1.global_position]\
#						,legs.MIDDLE_LEG : [joint1.global_position, joint2.global_position]\
#						,legs.LOWER_LEG : [joint2.global_position, tip.global_position]}
#	leg_length_dict = {legs.UPPER_LEG : length_upper\
#						,legs.MIDDLE_LEG : length_middle\
#						,legs.LOWER_LEG : length_lower}
#
#	# iteratively solves the IK, stop when can't solve or the distance margin met ie solved
#	var count = 0
#	while count < 213 and (abs((leg_pos_dict[2][1] - target_pos).length()) > MIN_DIST_MARGIN):
#		final_to_root(target_pos)
#		root_to_final()
#		count += 1

#	# Rotates the legs accordingly so calculated positions
#	var upper_leg_vec = leg_pos_dict[0][1] - leg_pos_dict[0][0]
#	var middle_leg_vec = leg_pos_dict[1][1] - leg_pos_dict[1][0]
#	var lower_leg_vec = leg_pos_dict[2][1] - leg_pos_dict[2][0]
#
#	global_rotation = Vector2(1,0).angle_to(upper_leg_vec)
#	joint1.rotation = upper_leg_vec.angle_to(middle_leg_vec)
#	joint2.rotation = middle_leg_vec.angle_to(lower_leg_vec)

#func final_to_root(target_pos):
#	var current_goal = target_pos
#	var current_limb = legs.LOWER_LEG
#	while (current_limb >= legs.UPPER_LEG):
#		leg_pos_dict[current_limb][1]  = current_goal
#		leg_pos_dict[current_limb][0] = current_goal + (leg_pos_dict[current_limb][0] - current_goal).normalized() * leg_length_dict[current_limb]
#		current_goal = leg_pos_dict[current_limb][0]
#
#		constrain_limb(current_limb)
#		current_limb -= 1
#
#func root_to_final():
#	var current_goal = leg_origin_pos
#	var current_limb = legs.UPPER_LEG
#
#	while (current_limb <= legs.LOWER_LEG):
#		leg_pos_dict[current_limb][0] = current_goal
#		leg_pos_dict[current_limb][1] = current_goal + (leg_pos_dict[current_limb][1] - current_goal).normalized() * leg_length_dict[current_limb]
#		current_goal = leg_pos_dict[current_limb][1]
#
#		constrain_limb(current_limb)
#		current_limb += 1

#func constrain_limb(current_limb):
#	pass
#	match current_limb:
#		legs.LOWER_LEG:
#			var lower_leg_vec = leg_pos_dict[current_limb][1] - leg_pos_dict[current_limb][0]
#			var mid_leg_vec = leg_pos_dict[legs.MIDDLE_LEG][1] - leg_pos_dict[legs.MIDDLE_LEG][0]
#			if flipped and lower_leg_vec.angle_to(mid_leg_vec) > 0 or not flipped and lower_leg_vec.angle_to(mid_leg_vec) < 0:
#				leg_pos_dict[current_limb][1] = leg_pos_dict[current_limb][0] + mid_leg_vec.normalized() * leg_length_dict[current_limb]
#
#		legs.MIDDLE_LEG:
#			var mid_leg_vec = leg_pos_dict[current_limb][1] - leg_pos_dict[current_limb][0]
#			var upper_leg_vec = leg_pos_dict[legs.UPPER_LEG][1] - leg_pos_dict[legs.UPPER_LEG][0]
#			var angle =  mid_leg_vec.angle_to(upper_leg_vec)
#
#			if flipped and angle < -.01 or not flipped and angle > 0.01: # never full extention, very slighly flexed in correct direction
#				leg_pos_dict[current_limb][1] = leg_pos_dict[current_limb][0] + upper_leg_vec.normalized() * leg_length_dict[current_limb] * (1 if (leg_pos_dict[current_limb][1].y > leg_pos_dict[legs.UPPER_LEG][1].y) else -1)
#
#		legs.UPPER_LEG : # ensures doesnt not fold too onwards
#			var leg_vec = leg_pos_dict[current_limb][1] - leg_pos_dict[current_limb][0]
#			var angle_deg = rad2deg(global_position.angle_to_point(leg_pos_dict[current_limb][1]))
#			if not flipped:
#				if abs(angle_deg) > (180 - INWARD_FOLD_ANGLE_LIMIT): # if going very inwards
#					leg_pos_dict[current_limb][1] = leg_pos_dict[current_limb][0] + Vector2.UP.rotated(deg2rad(90 - INWARD_FOLD_ANGLE_LIMIT)) * leg_length_dict[current_limb] * sign (angle_deg)
#			else:
#				if abs(angle_deg) < INWARD_FOLD_ANGLE_LIMIT:
#					leg_pos_dict[current_limb][1] = leg_pos_dict[current_limb][0] + Vector2.UP.rotated(deg2rad(INWARD_FOLD_ANGLE_LIMIT) * sign(angle_deg)) * leg_length_dict[current_limb]
