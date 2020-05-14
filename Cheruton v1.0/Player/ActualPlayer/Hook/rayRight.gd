extends RayCast2D

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if is_colliding():
		owner.has_collide = true
		owner.x_limit_right = get_collision_point().x
	else:
		owner.x_limit_right = INF
		owner.has_collide = false
