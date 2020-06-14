extends State_Enemy

# PROCESSHIT: Short period of time to process the damage status of the enemy

var timer : float

func initialize():
	timer = 0.15

func run(delta):
	timer -= delta
	if (timer <= 0):
		# Player was sighted recently - Attack
		if(obj.player_sight):
			fsm.state_next = fsm.states.Attack
		else:
			fsm.state_next = fsm.states.Search#stub

func terminate():
	pass
