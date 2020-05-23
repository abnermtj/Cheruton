extends baseFSM

func _ready():
	states_map = {
		"idle": $idle,
		"run": $run,
		"jump": $jump,
		"fall": $fall,
		"hook": $hook,
		"slide" : $slide,
		"attack" : $attack,
		"wallslide" : $wallslide
	}

func _change_state(state_name):
	if not _active:
		return

	if not states_stack.empty(): # edge case when falling from platform without jump then jumping agin
		previous_state = states_stack[0]

	if ["jump", "fall"].has(state_name):
		owner.on_floor = false
	else:
		owner.on_floor = true

	print("changing to ", state_name)
	._change_state(state_name)

func _input(event):
	current_state.handle_input(event)

