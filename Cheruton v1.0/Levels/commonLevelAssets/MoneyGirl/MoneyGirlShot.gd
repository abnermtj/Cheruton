extends KinematicBody2D

const SPEED = 2000

var goal_obj
var velocity
var level # set by shooter

func _ready():
	level.shake_camera(.3, 20, 20, Vector2.RIGHT)

func _physics_process(delta):
	var goal_pos = goal_obj.global_position
	var dir = (goal_pos - global_position).normalized()
	velocity = dir * SPEED
	var col = move_and_collide(velocity * delta)

	rotation = global_position.angle_to_point(goal_pos) + PI


func _on_hurtBox_area_entered(area):
	level.shake_camera(.3, 20, 20, -velocity.normalized())
	queue_free()
