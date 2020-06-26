extends State_Enemy

# PROCESSHIT: Short period of time to process the damage status of the enemy

var timer : float

func initialize():
	timer = 0.05

func run(delta):
	aerial_pos_edit()
	obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
	timer -= delta
	if (timer <= 0):
		# Player was not sighted recently - Search
		if(fsm.state_prev.prev_state == fsm.states.Search):
			fsm.state_next = fsm.states.Search#stub
		else:
			fsm.state_next = fsm.states.Attack#stub

func terminate():
	pass
