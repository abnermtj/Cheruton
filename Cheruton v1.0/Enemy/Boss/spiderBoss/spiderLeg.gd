extends Position2D

const MIN_DIST = 100

onready var joint1 = $joint1
onready var joint2 = $joint1/joint2
onready var tip = $joint1/joint2/tip

var length_upper = 0 # length of each of the sections
var length_middle = 0
var length_lower = 0

export var flipped = true

var start_pos = Vector2()
var middle_pos = Vector2()
var cur_goal_pos = Vector2()
var step_height = 40 # max distance from ground btween each step
var step_rate = 0.5 # affects how long each step takes
var step_time = 0.0

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

	cur_goal_pos = goal_pos
	var tip_pos = tip.global_position

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
		target_pos = start_pos.linear_interpolate(middle_pos, step_time/0.5)
	elif step_percent < 1.0:
		target_pos = middle_pos.linear_interpolate(cur_goal_pos, step_time/0.5)
	else:
		target_pos = cur_goal_pos
	update_ik(target_pos)

func update_ik(target_pos):
	var offset = target_pos - global_position #from shoulder to foot
	var dist_to_target = offset.length()
	if dist_to_target < MIN_DIST:
		offset = offset / dist_to_target * MIN_DIST
		dist_to_target = MIN_DIST

	var base_r = offset.angle()



