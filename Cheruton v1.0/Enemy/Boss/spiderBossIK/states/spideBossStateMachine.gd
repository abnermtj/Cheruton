extends baseFSM

func _ready():
	states_map = {
		"idle": $idle,
		"run": $run,
		"jumpAttack" : $jumpAttack,
		"stabAttack" : $stabAttack,
		"stepBack" : $stepBack,
		"webShoot" : $webShoot,
	}

func _change_state(state_name):
	print("changing to ", state_name)
	._change_state(state_name)
