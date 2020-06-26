extends State_Enemy

# PROCESSHIT: Short period of time to process the damage status of the enemy

var timer : float

func initialize():
	timer = 0.15

func run(delta):
	aerial_pos_edit()
	timer -= delta
	if (timer <= 0):
		# Player was sighted recently - Attack
		fsm.state_next = fsm.states.Search

func terminate():
	pass
