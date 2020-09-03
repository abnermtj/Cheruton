extends Node2D

const LIFETIME = 1
const GRAVITY = 90

var prev_points : PoolVector2Array
var cur_points : PoolVector2Array
var length : int
var num_points : int
var unit_length : float
var col_outline : Color
var col_inner : Color
var width : float
var timer : float

func init(_cur_points_array, _prev_points_array, _length, no_points, color_outline, color_inner, line_width, tip_rotation):
	prev_points = _prev_points_array
	cur_points = _cur_points_array

	var offset = get_parent().global_position

	$tip.global_position = cur_points[0] + offset
	$tip.rotation = tip_rotation - PI/2
	# for the very last point that attaches to the player,we make it have more speed to exaggerate speeed player leaves the rope
	prev_points[-1] += prev_points[-1] - cur_points[-1]

	length = _length
	num_points = no_points
	unit_length = length / num_points

	col_outline = color_outline
	col_inner = color_inner
	width = line_width

	timer = LIFETIME

# Verlet Integration to simulate rope physics
func _process(delta):
	timer -= delta
	if timer < 0 :
		queue_free()

	var percent_completion = timer / LIFETIME
	modulate.a = percent_completion * percent_completion
	_update(delta)
	for i in 100:
		_constrain(delta)
	_render()

func _update(delta):
	for i in num_points:
		if i == 0: continue
		var velocity = (cur_points[i] - prev_points[i]) * .982 # air resistance
		prev_points[i] = cur_points[i]
		cur_points[i] += velocity
		cur_points[i].y += GRAVITY * delta

func _constrain(delta):
	for i in num_points-1:
		var vector = cur_points[i+1] - cur_points[i]
		var dist = (cur_points[i+1] - cur_points[i]).length()
		var error = dist - unit_length

		vector *= error / dist
		if i == 0:
			cur_points[i+1] -= vector
		else :
			cur_points[i+1] -= vector/ 2
			cur_points[i] += vector/ 2

func _render():
	update()

func _draw():
	if cur_points.size()> 1:
		draw_polyline(cur_points,col_outline, width)
		draw_polyline(cur_points,col_inner, width-10)
