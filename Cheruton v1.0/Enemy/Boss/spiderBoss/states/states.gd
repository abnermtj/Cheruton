extends baseFSM

func _ready():
	states_map = {
		"idle": $idle,
		"run": $run,
		"jumpattack" : $jumpattack,
		"legsweep" : $legsweep,
		"webshoot" : $webshoot,
		"stabattack" : $stabattack,
		"dashattack" : $dashattack
	}

func _change_state(state_name):
	print("changing to ", state_name)
	._change_state(state_name)
