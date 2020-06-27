extends RigidBody2D

const THROW_VEL = Vector2(800, -400)
const GRAVITY = 1000
const LIFETIME = 2

var count

func _ready():
	count = 0
	applied_force = Vector2(0, GRAVITY)
	$Timer.start(LIFETIME)

func start_shoot(initial_pos, desired_pos, height): # dir has to be normalzied
	apply_central_impulse(calc_initial_velocity(initial_pos, desired_pos, height))

# uses kinematic equation to solve for initial velocity such that it will hit desired pos
func calc_initial_velocity(initial_pos, desired_pos, height):
	var x_displacement = desired_pos.x - initial_pos.x
	var y_displacement = desired_pos.y - initial_pos.y

	var initial_x_vel = x_displacement / ( sqrt(-2*height/GRAVITY) + sqrt(2* (y_displacement-height) /GRAVITY) )
	var initial_y_vel = sqrt(-2*GRAVITY*height)

	return Vector2(initial_x_vel, initial_y_vel)

func _on_acidProjectile_body_entered(body):
	count += 1
	if count == 5:
		queue_free()
func _on_Timer_timeout():
	queue_free()
