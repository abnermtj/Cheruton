extends State_Enemy



func initialize():
	#node.anim_nxt = "run"
	pass


func run( _delta ):
	if node.check_wall():
		node.dir_nxt = -node.dir_cur
	
	node.vel.x = node.dir_cur * 20
	node.vel.y = 0#min( node.vel.y + 500 * delta, 160 )
	node.vel = node.move_and_slide_with_snap( node.vel, \
			Vector2.DOWN * 8, \
			Vector2.UP )
