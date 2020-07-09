#extends Node2D
#
## lerp coefficients
#const SHOOT_OFFSET_INCREASE = -1
#const SHOOT_AMP_DECREASE = 2.3
#const SHOOT_WID_DECREASE = 2.4
#const LINE_WIDTH = 12
#
#var length_divisor = 1 #used to get the number of points in the line, we then connect those points via polyline
#
#var stage
#const INITIAL_SHOOT = 1
#const JUST_HOOKED = 2
#const RETRACT = 3
#
#var color_outline = Color(0.07843, 0.0627, 0.125)
#var color_inner = Color(.9,.9,.9)
#export (Curve) var attachment_curve
#
#var length
#var c = 1 # set in player function # similar to offset
#var s = .68 #  inverse wave length # 2
#var w = 1# wave length
#var a = 1# amplitude
#
#func _draw(): # gets called once initially then again when update() is called
#	var points_arr = PoolVector2Array() # an array specifically to hold Vector2
#
#	length = c
#	var d = c/(w+(1-s)*w)
#	for point_idx in range (length/length_divisor):
#		var y_pos = (-4 * pow(2, point_idx/c - 0.5) + 1) * a * sin(((point_idx-c) * d * PI) / c) * s # makes the link wobble during travel
#		points_arr.push_back(Vector2(point_idx*length_divisor, y_pos))
#	if points_arr.size()> 1:
#		draw_polyline(points_arr,color_outline, LINE_WIDTH)
#		draw_polyline(points_arr,color_inner, LINE_WIDTH-10)
#
#func start():
#	var rand_num1 = rand_range(-3, 3)
#	var rand_num2 = rand_range(-4, 4)
#	var rand_num3 = rand_range(-.1, .1)
#	stage = INITIAL_SHOOT
#	w = 7 + rand_num1
#	a = 18 +rand_num2
#	s = .68 + rand_num3
#
#func release():
#	stage = RETRACT
#	a = 0
#
#func _process(delta):
#	if not visible:
#		return
#	if stage == INITIAL_SHOOT:
#		length_divisor = 1
#		s = lerp(s, 1, delta*SHOOT_OFFSET_INCREASE)
#		a = lerp(a, 1, delta*SHOOT_AMP_DECREASE)
#		w = lerp(w, w*16, delta*SHOOT_WID_DECREASE)
#		if owner.chain_state == owner.chain_states.HOOKED:
#			stage = JUST_HOOKED
#			s = .4
#	elif stage == JUST_HOOKED:
#		s = attachment_curve.interpolate(s)
#		a = 40
#		length_divisor = lerp(length_divisor,c/100,delta) # 'c' boosts performance by reducing points
#	elif stage == RETRACT:
#		length_divisor = 1
#	update()

extends Node2D

# lerp coefficients
const SHOOT_OFFSET_INCREASE = -1
const SHOOT_AMP_DECREASE = 2.3
const SHOOT_WID_DECREASE = 2.4
const LINE_WIDTH = 12

const INITIAL_SHOOT = 1
const JUST_HOOKED = 2
const RETRACT = 3
var stage

var length_divisor = 1 #used to get the number of points in the line, we then connect those points via polyline

export (Curve) var attachment_curve
var color_outline = Color(0.07843, 0.0627, 0.125)
var color_inner = Color(.9,.9,.9)
var points_arr = PoolVector2Array()

var length
var c = 1 # set in player function equal to length of rope # similar to offset of a graph
var s = .68 #  inverse wave length # 2
var w = 1 # wave length
var a = 1 # amplitude

var num_points : int
var desired_length : float

func _draw(): # gets called once initially then again when update() is called
	points_arr.resize(0)

	length = c
	var d = c/(w+(1-s)*w)

	num_points = length/length_divisor
	for point_idx in range (num_points):
		var y_pos = (-4 * pow(2, point_idx/c - 0.5) + 1) * a * sin(((point_idx-c) * d * PI) / c) * s # makes the link wobble during travel
		points_arr.push_back(Vector2(point_idx*length_divisor, y_pos))
	if points_arr.size()> 1:
		draw_polyline(points_arr,color_outline, LINE_WIDTH)
		draw_polyline(points_arr,color_inner, LINE_WIDTH-10)

func start():
	var rand_num1 = rand_range(-3, 3)
	var rand_num2 = rand_range(-4, 4)
	var rand_num3 = rand_range(-.1, .1)
	stage = INITIAL_SHOOT
	w = 7 + rand_num1
	a = 18 +rand_num2
	s = .68 + rand_num3

	show()

func release():
	stage = RETRACT
	var tip_pos = owner.tip.global_position

	num_points = length / 10 # saves performance draws less points
	var rope_vec = owner.cur_player_pos - tip_pos
	var rope_segement_vec = rope_vec/num_points

	var cur_points_pos = PoolVector2Array()
	for i in num_points:
		cur_points_pos.append(tip_pos + i * rope_segement_vec) # first point is at the tip (anchor)

	rope_vec = owner.prev_player_pos - tip_pos
	rope_segement_vec = rope_vec/num_points

	var prev_points_pos = PoolVector2Array()
	for i in num_points:
		prev_points_pos.append(tip_pos + i * rope_segement_vec)

	var free_rope = load("res://Player/ActualPlayer/Hook/freeRope.tscn")
	var child = free_rope.instance()
	owner.get_parent().add_child(child)

	child.init(cur_points_pos , prev_points_pos, length, num_points, color_outline, color_inner, LINE_WIDTH)
	child.global_position = Vector2(0,0)

	hide()

func _process(delta):
	if not visible:
		return
	if stage == INITIAL_SHOOT:
		length_divisor = 1
		s = lerp(s, 1, delta*SHOOT_OFFSET_INCREASE)
		a = lerp(a, 1, delta*SHOOT_AMP_DECREASE)
		w = lerp(w, w*16, delta*SHOOT_WID_DECREASE)
		if owner.chain_state == owner.chain_states.HOOKED:
			stage = JUST_HOOKED
			s = .4
		update() # draws line to canvas
	elif stage == JUST_HOOKED:
		s = attachment_curve.interpolate(s)
		a = 40
		length_divisor = lerp(length_divisor,c/100,delta) # 'c' boosts performance by reducing points
		update()

