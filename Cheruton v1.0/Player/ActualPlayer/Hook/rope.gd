extends Node2D

# lerp coefficients
const SHOOT_OFFSET_INCREASE = -1
const SHOOT_AMP_DECREASE = 1.8
const SHOOT_WID_DECREASE = 2.3

var color = Color(0.756, 0.819, 0.858)
export (Curve) var attachment_curve
var stage

# coefficients for  equation
var length
var c= 1 # set in player function
var s = .68
var w
var a
var rng = RandomNumberGenerator.new()

# only called when visible, so if parents sets it to not visible, this won't be called
func _draw(): # gets called once initially then again when update() is called
		var points_arr = PoolVector2Array() # an array specifically to hold Vector2

		length = c
		var d = c/(w+(1-s)*w)
		for point_idx in range (length):
			var y_pos = (-4 * pow(2, point_idx/c - 0.5) + 1) * a * sin(((point_idx-c) * d * PI) / c) * s
			points_arr.push_back(Vector2(point_idx, y_pos))

		for line_end_idx in range(length-1):
			draw_line(points_arr[line_end_idx], points_arr[line_end_idx + 1], color,4)
		points_arr.resize(0) # same array is used in differennt function calls

func start():
	rng.randomize()
	var rand_num1 = rng.randf_range(-3, 3)
	var rand_num2 = rng.randf_range(-4, 4)
	var rand_num3 = rng.randf_range(-.1, .1)
	stage = 1
	w = 36.7 + rand_num1
	a = 18 +rand_num2
	s = .68 + rand_num3

func release():
	rng.randomize()
	var rand_num1 = rng.randf_range(-3, 3)
	var rand_num2 = rng.randf_range(-4, 4)
	var rand_num3 = rng.randf_range(-.1, .1)
	stage = 3
	w = 36.7 + rand_num1
	a = 18 +rand_num2
	s = .68 + rand_num3

func _process(delta):
	if not self.visible:
		return
	if stage == 1:
		s = lerp(s,1,delta*SHOOT_OFFSET_INCREASE)
		a = lerp(a, 0, delta*SHOOT_AMP_DECREASE)
		w = lerp(w,w*4.4,delta*SHOOT_WID_DECREASE)

		if owner.	hooked:
			stage = 2
			s = .4
	elif stage == 2:
		s = attachment_curve.interpolate(s)
		a = 40
	elif stage == 3:
		s = lerp(s,1,delta*SHOOT_OFFSET_INCREASE)
		a = lerp(a, 0, delta*SHOOT_AMP_DECREASE)
		w = lerp(w,w*4.4,delta*SHOOT_WID_DECREASE)

	update()


