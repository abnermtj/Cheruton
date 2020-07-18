extends KinematicBody2D

const SPEED = 2000

var goal_obj

func _physics_process(delta):
	var goal_pos = goal_obj.global_position
	var dir = (goal_pos - global_position).normalized()
	var velocity = dir * SPEED
	var col = move_and_collide(velocity * delta)

	rotation = global_position.angle_to_point(goal_pos) + PI


func _on_hurtBox_area_entered(area):
	queue_free()
