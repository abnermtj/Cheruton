extends Position2D

const MIN_DIST = 130 # used so it doesn't dissapear 118 min

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
var cur_goal_pos = Vector2()
var step_height = 30
var step_rate = 0.24 # actual time taken to complete a step default i .2
var step_time = 0.0
var is_step_over = false
var total_rotation = 0.0

func _ready():
	length_upper = joint1.position.x
	length_middle = joint2.position.x
	length_lower = tip.position.x
	if flipped:
		$Sprite.flip_h = true
		joint1.get_node("Sprite").flip_h = true
		joint2.get_node("Sprite").flip_h = true

func step(goal_pos):
	if goal_pos == cur_goal_pos: return

	is_step_over = false

	cur_goal_pos = goal_pos
	tip_pos = tip.global_position

	var highest_y = max (goal_pos.y, tip_pos.y)

	var mid_x = (goal_pos.x + tip_pos.x)/ 2.0
	start_pos = tip_pos
	middle_pos = Vector2(mid_x, highest_y - step_height)
	step_time = 0.0

func _process(delta):
	step_time += delta
	var target_pos = Vector2()
	var step_percent = step_time / step_rate # percentage of the step completed

	if step_percent < .5:
		target_pos = start_pos.linear_interpolate(middle_pos, step_percent * 2)
	elif step_percent < 1.0:
		target_pos = middle_pos.linear_interpolate(cur_goal_pos, (step_percent-.5) * 2)
	else:
		target_pos = cur_goal_pos
		is_step_over = true
		tip_pos = target_pos

#	target_pos = get_viewport().get_mouse_position()
	update_ik(target_pos)
	total_rotation = joint1.rotation_degrees + joint2.rotation_degrees

func update_ik(target_pos):
	var offset = target_pos - global_position #from shoulder to foot
	var dist_to_target = offset.length()
	if dist_to_target < MIN_DIST:
		offset = offset / dist_to_target * MIN_DIST
		dist_to_target = MIN_DIST

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
