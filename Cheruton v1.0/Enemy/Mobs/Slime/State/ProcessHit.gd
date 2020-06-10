extends State_Enemy

var timer : float

func initialize():
	timer = 0.15
	obj.anim_next = "Patrol"#debug


func run(delta):
	timer -= delta
	if (timer <= 0):
		if(obj.player_sight):
			fsm.state_next = fsm.states.Attack
		else:
			fsm.state_next = fsm.states.Search#stub

func terminate():
	obj.get_node("DamageBox/DamageCollision").disabled = false
