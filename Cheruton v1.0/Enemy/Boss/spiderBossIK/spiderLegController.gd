extends Position2D

# This script manages the relationship between the ik leg and the raycast
class_name SpiderLegController

onready var leg = $leg
onready var ray_cast = $RayCast2D
onready var diag_ray_cast = $RayCast2D2
onready var floor_ray_cast = $RayCast2D3
onready var base_offset = $RayCast2D.position.x
onready var base_cast = $RayCast2D.cast_to
onready var base_offset_diag = $RayCast2D2.position.y
onready var base_cast_diag = $RayCast2D2.cast_to

func force_raycast_update():
	ray_cast.force_raycast_update()
	diag_ray_cast.force_raycast_update()

# Getters
func is_step_over(): # note leg is grounded once timer is up not whe actually grouded
	return leg.is_step_over
func is_flipped():
	return leg.flipped
func get_tip_dist_to_point(point):
	return leg.get_dist_tip_to_point(point)
func get_tip_pos():
	return leg.tip_pos
func get_dist_from_desired():
	var col_point = get_collision_point()
	if not col_point: return
	return get_tip_dist_to_point(col_point)
func get_leg_extension_deg():
	return leg.total_rotation

# Collision checks
func is_colliding_ground():
	return true if ray_cast.is_colliding() else false
# this function returns null if ray cast is not colliding
func get_collision_point():
	var col_point

	# I used not col_point condition here as it allows for shifting the order of checks
	if not col_point and owner.diag_ray_cast_enable and diag_ray_cast.is_colliding():
		col_point = diag_ray_cast.get_collision_point()
		if col_point:
			var normal = diag_ray_cast.get_collision_normal()
			var angle = rad2deg(acos(normal.dot(Vector2.UP)))
			if abs(angle) < 60: #  floor or wall
					col_point = null
	if not col_point and owner.norm_ray_cast_enable and ray_cast.is_colliding():
		col_point = ray_cast.get_collision_point()
		if col_point:
			var normal = diag_ray_cast.get_collision_normal()
			var angle = rad2deg(acos(normal.dot(Vector2.UP)))
			if abs(angle) != 0: #  floor
					col_point = null
	if not col_point and owner.floor_ray_cast_enable and floor_ray_cast.is_colliding(): col_point = floor_ray_cast.get_collision_point()
	return col_point

func set_offset(vel):
	ray_cast.position.x = base_offset + vel.x * 1.5
	ray_cast.cast_to.x = base_cast.x + .2 * vel.x
	diag_ray_cast.position.y =  base_offset_diag + clamp(vel.y  * 2.6, -250, INF) # clamp so scaling up doesn't make spider reach very far
	diag_ray_cast.cast_to = base_cast_diag + sign(vel.x)* (1 if sign(vel.x) == sign(base_cast_diag.x) else 0 ) *  Vector2(clamp(abs(vel.x)*.75 + int(not is_colliding_ground()) * 400, 0, INF), 0)  # if no where to place foot , boost diagonal vector
	force_raycast_update()

#Relaying funtion
func step(pos):
	leg.step(pos)
