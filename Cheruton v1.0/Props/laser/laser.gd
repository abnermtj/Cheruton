extends Node2D

onready var laser_beam = $laser_sprite_center
onready var laser_particles = $hitParticles

export var rotating : bool = false
export var angular_vel_deg : float = 1.0
export var max_dist : float = 1000.0
export var starting_rot_deg: float = 0.0

var hit_pos : Vector2

func _ready():
	rotation_degrees = starting_rot_deg

func _physics_process(delta):
	if rotating: rotate(deg2rad(angular_vel_deg))

	hit_pos = global_position + transform.x * max_dist # assume it hits at max distance
	var space = get_world_2d().direct_space_state
	var col = space.intersect_ray(global_position, hit_pos, [self], 1, true, true) # transform.x contains the rotation reperesented by a unit vector, '.y' member is the same rotation but in the oppsite direction and '.origin' member is the global transformation

	if col:
		hit_pos = col.position
		var laser_length = laser_beam.global_position.distance_to(hit_pos)
		laser_beam.region_rect.size.x = laser_length

		laser_particles.show()
		laser_particles.global_position = hit_pos
	else:
		laser_particles.hide()
		laser_beam.region_rect.size.x = max_dist

	$CollisionShape2D.shape.b = Vector2(hit_pos.distance_to(global_position), 0) # uses regions to repeat the texture

