extends State_Enemy

# PATROL: Enemy moves around the terrain it is limited to
var random = RandomNumberGenerator.new()
var speed = 105
var rax = 1

func initialize():
	random.randomize()
	obj.anim_next = "Patrol"
	obj.velocity.y = random.randf_range(100, 200)

func run(_delta):
	
	# Wall or empty gap encountered
	if (obj.change_patrol_dirn()):
		obj.dir_next = -obj.dir_curr
	obj.velocity.x = obj.dir_curr * speed
	obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
