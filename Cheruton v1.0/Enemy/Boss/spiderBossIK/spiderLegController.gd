extends Position2D

# This script manages the relationship between the ik leg and the raycast
class_name SpiderLegController

onready var ray_cast = $RayCast2D
onready var leg = $leg
onready var base_offset = $RayCast2D.position.x


func force_raycast_update():
	ray_cast.force_raycast_update()

func is_colliding():
	return true if ray_cast.is_colliding() else false

func get_collision_point():
	return ray_cast.get_collision_point()

func step(target_pos : Vector2):
	leg.step(target_pos)

func is_grounded():
	return leg.is_grounded
func get_tip_dist_to_point(point):
	return leg.get_dist_tip_to_point(point)

func get_dist_from_desired():
	var col_point
	if is_colliding():  col_point = get_collision_point()
	return get_tip_dist_to_point(col_point)

func get_leg_extension_deg():
	return leg.total_rotation

# used to increase offset with the speed of the spider
func set_offset(val):
	ray_cast.position.x = base_offset + val
