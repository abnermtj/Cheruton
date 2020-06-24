extends Position2D

const MIN_LENGTH = 370 # used so it doesn't dissapear 118 min
const step_rate = 0.38 # actual time taken to complete a step default i .2
const step_height = 80
const MIN_DIST_MARGIN = 3
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
# used for fabrik
var leg_origin_pos : Vector2
var leg_pos_dict = {}
var prev_leg_pos_dict = {}
var leg_length_dict = {}

func _ready():
	length_upper = joint1.position.x
	length_middle = joint2.position.x
	length_lower = tip.position.x
	if flipped:
		$Sprite.flip_h = true
		joint1.get_node("Sprite").flip_h = true
		joint2.get_node("Sprite").flip_h = true

func step(target_pos):
	if target_pos == cur_target_pos: return

	is_step_over = false

	cur_target_pos = target_pos
	tip_pos = tip.global_position

	var highest_y = max (target_pos.y, tip_pos.y)

	var mid_x = (target_pos.x + tip_pos.x)/ 2.0
	start_pos = tip_pos
	middle_pos = Vector2(mid_x, highest_y - step_height)
	step_time = 0.0

func _process(delta):
	step_time += delta
	var target_pos = Vector2()
	var step_percent = step_time / step_rate # percentage of the step completed

	if step_percent < .5:
		target_pos = start_pos.linear_interpolate(middle_pos, step_percent * 2)
#		target_pos = start_pos + step_percent*  PI /2
	elif step_percent < 1.0:
		target_pos = middle_pos.linear_interpolate(cur_target_pos, (step_percent-.5) * 2)
	else:
		target_pos = cur_target_pos
		is_step_over = true
		tip_pos = target_pos

	target_pos = get_viewport().get_mouse_position()
	update_ik(target_pos)

	total_rotation = joint1.rotation_degrees + joint2.rotation_degrees

# SSS Implmentation
#func update_ik(target_pos):
#	var offset = target_pos - global_position #from shoulder to foot
#	var dist_to_target = offset.length()
#	if dist_to_target < MIN_LENGTH:
#		offset = offset / dist_to_target * MIN_LENGTH
#		dist_to_target = MIN_LENGTH
#
#	var base_r = offset.angle() # used to make the bottom triangle in the diagram flat on the floor
#	var length_total = length_lower + length_middle + length_upper
#	var length_dummy_side = (length_upper + length_middle) * clamp(dist_to_target / length_total, 0.0, 1.0)
#
#	var base_angles = angles_of_triangle(length_dummy_side, length_lower, dist_to_target)
#	var next_angles = angles_of_triangle(length_upper, length_middle, length_dummy_side)
#
#	global_rotation = base_angles.B + next_angles.B + base_r
#	joint1.rotation = next_angles.C
#	joint2.rotation = base_angles.C + next_angles.A

# FABRIK IMPLMENTATION TEST
func update_ik(target_pos):
	var vec_to_target = target_pos - global_position
	if vec_to_target.length() < MIN_LENGTH:
		target_pos = global_position + MIN_LENGTH * vec_to_target.normalized()

	var end_effector_pos = tip.global_position
	leg_origin_pos = global_position

	leg_pos_dict = {legs.UPPER_LEG : [global_position, joint1.global_position]\
						,legs.MIDDLE_LEG : [joint1.global_position, joint2.global_position]\
						,legs.LOWER_LEG : [joint2.global_position, tip.global_position]}
	leg_length_dict = {legs.UPPER_LEG : length_upper\
						,legs.MIDDLE_LEG : length_middle\
						,legs.LOWER_LEG : length_lower}

	var count = 0
	while count < 200 and (abs((leg_pos_dict[2][1] - target_pos).length()) > MIN_DIST_MARGIN):
		final_to_root(target_pos)
		root_to_final()
		prev_leg_pos_dict = leg_pos_dict
		count += 1

	var upper_leg_vec = leg_pos_dict[0][1] - leg_pos_dict[0][0]
	var middle_leg_vec = leg_pos_dict[1][1] - leg_pos_dict[1][0]
	var lower_leg_vec = leg_pos_dict[2][1] - leg_pos_dict[2][0]

	global_rotation = Vector2(1,0).angle_to(upper_leg_vec)
	joint1.rotation = upper_leg_vec.angle_to(middle_leg_vec)
	joint2.rotation = middle_leg_vec.angle_to(lower_leg_vec)

func final_to_root(target_pos):
	var current_goal = target_pos
	var current_limb = legs.LOWER_LEG
	while (current_limb >= legs.UPPER_LEG):
		leg_pos_dict[current_limb][1]  = current_goal
		leg_pos_dict[current_limb][0] = current_goal + (leg_pos_dict[current_limb][0] - current_goal).normalized() * leg_length_dict[current_limb]
		current_goal = leg_pos_dict[current_limb][0]

		constrain_limb(current_limb)
		current_limb -= 1

func root_to_final():
	var current_goal = leg_origin_pos
	var current_limb = legs.UPPER_LEG

	while (current_limb <= legs.LOWER_LEG):
		leg_pos_dict[current_limb][0] = current_goal
		leg_pos_dict[current_limb][1] = current_goal + (leg_pos_dict[current_limb][1] - current_goal).normalized() * leg_length_dict[current_limb]
		current_goal = leg_pos_dict[current_limb][1]

		constrain_limb(current_limb)
		current_limb += 1

func constrain_limb(current_limb):

	match current_limb:
		legs.LOWER_LEG:
			var lower_leg_vec = leg_pos_dict[current_limb][1] - leg_pos_dict[current_limb][0]
			var mid_leg_vec = leg_pos_dict[legs.MIDDLE_LEG][1] - leg_pos_dict[legs.MIDDLE_LEG][0]

			if flipped and lower_leg_vec.angle_to(mid_leg_vec) > 0 or not flipped and lower_leg_vec.angle_to(mid_leg_vec) < 0:
				leg_pos_dict[current_limb][1] = leg_pos_dict[current_limb][0] + mid_leg_vec.normalized() * leg_length_dict[current_limb]
		legs.MIDDLE_LEG:
			var mid_leg_vec = leg_pos_dict[current_limb][1] - leg_pos_dict[current_limb][0]
			var upper_leg_vec = leg_pos_dict[legs.UPPER_LEG][1] - leg_pos_dict[legs.UPPER_LEG][0]

			if flipped and mid_leg_vec.angle_to(upper_leg_vec) < 0.2 or not flipped and mid_leg_vec.angle_to(upper_leg_vec) > 0.2: # approaching full extention
				# trying to lower start of middle leg to lower the angle and avoid extension
				leg_pos_dict[legs.UPPER_LEG][1] = upper_leg_vec.rotated(deg2rad(5 * (1 if flipped else -1))) + leg_pos_dict[legs.UPPER_LEG][0]
				leg_pos_dict[current_limb][0] = leg_pos_dict[legs.UPPER_LEG][1]
				leg_pos_dict[current_limb][1] = leg_pos_dict[current_limb][0] + (leg_pos_dict[current_limb][1] - leg_pos_dict[current_limb][0]).normalized() * leg_length_dict[current_limb]
			if flipped and mid_leg_vec.angle_to(upper_leg_vec) < 0 or not flipped and mid_leg_vec.angle_to(upper_leg_vec) > 0: # fully exteneded
				leg_pos_dict[current_limb][1] = leg_pos_dict[current_limb][0] + upper_leg_vec.normalized() * leg_length_dict[current_limb]
		legs.UPPER_LEG : # constrains to never fold inwards
			var leg_vec = leg_pos_dict[current_limb][1] - leg_pos_dict[current_limb][0]
			if (flipped and leg_vec.x < 0) or (not flipped and leg_vec.x > 0):
				leg_pos_dict[current_limb][1] = leg_pos_dict[current_limb][0] + Vector2(0,leg_length_dict[current_limb] * sign(leg_vec.y))

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




