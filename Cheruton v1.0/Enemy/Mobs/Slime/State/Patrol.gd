extends State_Enemy

# PATROL: Enemy moves around the terrain it is limited to

var speed = 105

func initialize():
	obj.anim_next = "Patrol"

func run(_delta):
	should_fall()
	# Wall or empty gap encountered
	if (obj.change_patrol_dirn()):
		obj.dir_next = -obj.dir_curr
	obj.velocity.x = obj.dir_curr * speed
	obj.velocity.y = 0
	obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
