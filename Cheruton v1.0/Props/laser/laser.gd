extends Node2D

const MAX_DIST = 1000

onready var laser_beam = $laser_sprite_center
onready var laser_particles = $hitParticles

func _physics_process(delta):
	handle_beam()
	handle_movement()


func handle_beam():
	var ray = get_world_2d().direct_space_state
	var hit = ray.intersect_ray(global_position, global_position + transform.x * MAX_DIST, [self], 1, true, true) # transform.x contains the rotation reperesented by a unit vector, .y member is the same rotation but in the oppsite direction and .origin member is the global transformation

	if hit:
		var hit_pos = hit.position
		var laser_length = laser_beam.global_position.distance_to(hit_pos)
		laser_beam.region_rect.size.x = laser_length
#		laser_beam.scale.x = laser_length

		laser_particles.show()
		laser_particles.global_position = hit_pos
	else:
		laser_particles.hide()
		laser_beam.region_rect.size.x = MAX_DIST
#		laser_beam.scale.x = MAX_DIST

func handle_movement():
	global_position = get_global_mouse_position()
	if Input.is_action_pressed("jump"):
		rotation_degrees += 3
	if Input.is_action_pressed("hook"):
		rotation_degrees -= 3

