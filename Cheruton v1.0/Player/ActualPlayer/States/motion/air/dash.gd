extends airState

const SPEED_BOOST = 600
const MAX_SPEED = 1500
var dir

func enter():
	owner.can_dash = false
	dir = get_input_direction()
	owner.velocity.y *= .1
	if dir.x == -1:
		owner.velocity += Vector2(-1,-2).normalized() * SPEED_BOOST
	elif dir.x == 1:
		owner.velocity += Vector2(1,-2).normalized()* SPEED_BOOST
	else:
		owner.velocity += Vector2.UP * SPEED_BOOST
	owner.velocity.x = clamp(owner.velocity.x, -MAX_SPEED, MAX_SPEED)
	owner.move()
	emit_signal("finished", "fall")

func update(delta):
	pass
