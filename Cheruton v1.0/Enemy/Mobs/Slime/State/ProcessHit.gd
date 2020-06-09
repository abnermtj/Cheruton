extends State_Enemy

var timer : float

func initialize():
	timer = 0.15
	obj.anim_next = "hit"


func run(delta):
	timer -= delta
	if timer <= 0:
		fsm.state_next = fsm.states.Patrol#stub

func terminate():
	print(122)
	obj.get_node("DamageBox/DamageCollision").disabled = false
