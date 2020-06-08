extends State_Enemy


func initialize():
	obj.anim_next = "run"


func run(_delta):
	if (obj.check_wall()):
		obj.dir_next = -obj.dir_curr
	
	obj.velocity.x = obj.dir_curr * 20
	obj.velocity.y = 0#min( obj.vel.y + 500 * delta, 160 )
	obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
