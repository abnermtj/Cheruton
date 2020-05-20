extends baseFSM

func _ready():
	states_map = {
		"idle": $idle,
		"run": $run,
		"jump": $jump,
		"fall": $fall,
		"hook": $hook,
		"slide" : $slide
	}

func _change_state(state_name):
	if not states_stack.empty(): # edge case when falling from platform without jump then jumping agin
		previous_state_name = states_stack[0].name
	if state_name != "previous" and states_map[state_name] is airState:
		owner.on_floor = false
	else:
		owner.on_floor = true
	if(state_name != "previous" and states_map[state_name] == current_state):
		return

	print("changing to ", state_name)
	if not _active:
		return

	if (state_name in ["stagger", "jump", "attack", "hook"]):  # these are allowed to be placed ontop of other states
		states_stack.push_front(states_map[state_name])
	._change_state(state_name)

func _input(event):
	current_state.handle_input(event)

