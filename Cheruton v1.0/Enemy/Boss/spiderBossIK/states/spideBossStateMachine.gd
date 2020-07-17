extends baseFSM

func _change_state(state_name):
	print("changing to ", state_name)
	._change_state(state_name)
