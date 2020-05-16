extends RayCast2D

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if is_colliding():
		owner.has_collide = true
		owner.y_limit = get_collision_point().y
#		print (owner.y_limit)
	else:
		owner.y_limit = INF
		owner.has_collide = false
