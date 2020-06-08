extends State_Enemy

var speed = 35

func initialize():
	obj.anim_next = "run"


func run(_delta):
	if (obj.check_horizontal_wall()):
		print("Yes")
		obj.dir_next = -obj.dir_curr
	else:
		print("No")
	obj.velocity.x = obj.dir_curr * speed
	obj.velocity.y = 0#min(obj.velocity.y + 500 * _delta, 160)
	obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
