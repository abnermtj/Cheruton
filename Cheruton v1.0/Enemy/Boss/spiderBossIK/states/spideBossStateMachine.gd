extends baseFSM

func _ready():
	states_map = {
		"idle": $idle,
		"run": $run,
		"jumpAttack" : $jumpAttack,
		"legSweep" : $legSweep,
		"webShoot" : $webShoot,
		"stabAttack" : $stabAttack,
		"dashAttack" : $dashAttack
	}

func _change_state(state_name):
	print("changing to ", state_name)
	._change_state(state_name)
