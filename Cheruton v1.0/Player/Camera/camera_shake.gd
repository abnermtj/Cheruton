extends Camera2D
class_name ShakeCamera

const LOOK_AHEAD_FACTOR = 0.1 # percentage of screen to shift for looking ahead when changing directions
const SHIFT_TRANS = Tween.TRANS_SINE # choose transition here
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 2.0
const RIGHT_BIAS = 1.1 # show more of the screen when going right, ie forward in our game

var _duration := 0.0
var _period_in_ms := 0.0
var _amplitude := 0.0
var _timer := 0.0
var _last_shook_timer := 0.0
var _previous_x := 0.0
var _previous_y := 0.0
var _last_offset := Vector2(0, 0)
var _shakedir := Vector2( 1, 1 )

var shake_offset := Vector2()
var pan_offset := Vector2()
var target_pan_offset := Vector2()
var pan_speed := 3.0

var slowmo_target = Vector2()
var slowmo_offset = Vector2()

var facing = 0
onready var prev_camera_pos = get_camera_position()
onready var tween = $ShiftTween # this caches a node no need to reload in downtimes between uses
func _ready():
#	game.camera = self
	call_deferred( "align_camera_now" )

func align_camera_now():
	# delay below is so that camera not always following player
	yield( get_tree().create_timer(0.1), 'timeout' ) #yeild freezess current fuction until told to resume
	# yield (object, signal signal from object to	 continue)
	# yeild is a coroutine, which interupts function and allows it to complete before continiuing
	align()
	reset_smoothing()


func _physics_process( delta ):
	# to make camera face forwards
	_check_facing()
	prev_camera_pos = get_camera_position()
	if _timer != 0:
		# Only shake on certain frames.
		_last_shook_timer = _last_shook_timer + delta
		# Be mathematically correct in the face of lag; usually only happens once.
		while _last_shook_timer >= _period_in_ms:
			_last_shook_timer = _last_shook_timer - _period_in_ms
			# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
			var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
			# Noise calculation logic from http://jonny.morrill.me/blog/view/14
			var new_x = rand_range(-1.0, 1.0)
			var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
			var new_y = rand_range(-1.0, 1.0)
			var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
			_previous_x = new_x
			_previous_y = new_y
			# Track how much we've moved the offset, as opposed to other effects.
			var new_offset = Vector2(x_component, y_component)
			shake_offset -= _last_offset - new_offset
			_last_offset = new_offset
		# Reset the offset when we're done shaking.
		_timer = _timer - delta
		if _timer <= 0:
			_timer = 0
			shake_offset -= _last_offset
	else:
		shake_offset = shake_offset.linear_interpolate( Vector2.ZERO, delta )
	# pan camera
	pan_offset = pan_offset.linear_interpolate( target_pan_offset, pan_speed * delta )
	if abs( pan_offset.y ) < 0.5:
		pan_offset.y = 0

	slowmo_offset = lerp( slowmo_offset, slowmo_target, 10 * delta )
	#print( slowmo_offset )

	if _timer != 0:
		if _shakedir == Vector2.ZERO:
			offset = shake_offset + pan_offset
		else:
			offset = shake_offset.length() * _shakedir + pan_offset
	else:
		offset = pan_offset
	offset += slowmo_offset

# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude, shakedir = Vector2.ZERO ):
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	_shakedir = shakedir
	shake_offset -= _last_offset
	_last_offset = Vector2.ZERO


# in target diretion until reached
func pan_camera( pan : Vector2 ) -> void:
	target_pan_offset = pan
	pass


func _check_facing():
	var new_facing = sign(get_camera_position().x - prev_camera_pos.x) # +1 camera moves to the right else -1 if left else 0
	if new_facing != 0 && facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * facing * LOOK_AHEAD_FACTOR
		if new_facing == 1:
			target_offset *= RIGHT_BIAS
		position.x = target_offset
		# modify the self object propery position:x, from the current positino to the target and use the following parementers:
		tween.interpolate_property(self, "position:x", position.x, target_offset, SHIFT_DURATION, SHIFT_TRANS, SHIFT_EASE)
		tween.start()

func _on_Player_grounded(grounded):
	print ("grounded is ",grounded)
#	if not grounded:
#		drag_margin_top = 1
#		drag_margin_bottom = 1
#	else:
#		drag_margin_top = 0.52
#		drag_margin_bottom = 0.67
##
	drag_margin_v_enabled = not grounded
