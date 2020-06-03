extends airState

const SPEED_BOOST = 1000
const SLOW_DOWN_DURATION = .2
const BOOST_DURATION = 1.23 # cannot be 0 else division by zero

onready var tween = $Tween

export (Curve) var boost_curve

var dir
var stage
var boost_timer
var pre_boost_vel

func enter():
	owner.can_dash = false
	stage = 0
	owner.velocity.y *= .6
	dir = get_input_direction().normalized()
	Engine.time_scale = .56
	tween.interpolate_property(owner,"velocity", owner.velocity, owner.velocity * .8, SLOW_DOWN_DURATION, Tween.TRANS_SINE,Tween.EASE_OUT)
	tween.start()

func _on_Tween_tween_completed(object, key):
	Engine.time_scale = 1
	owner.velocity += dir* SPEED_BOOST
	owner.velocity.y -= 80
	pre_boost_vel = owner.velocity
	stage += 1
	boost_timer = 0

func update(delta):
	if stage == 1: # ie boosting
		boost_timer += delta/BOOST_DURATION
		owner.velocity = pre_boost_vel * (1.01- boost_curve.interpolate(boost_timer))
		owner.velocity.y += owner.GRAVITY *.04
		if boost_timer > .3:
			emit_signal("finished", "fall")
	owner.move()


