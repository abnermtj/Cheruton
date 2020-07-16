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
		"wallSlide" : $wallSlide,
		"dash" : $dash,
		"hit" : $hit,
		"talk": $talk
	}

func _change_state(state_name):
	if not _active:
		return

	if states_stack:
		previous_state = states_stack[-1]

	if ["jump", "fall", "attack"].has(state_name):
		owner.on_floor = false
	else:
		owner.on_floor = true

	print("changing to ", state_name)
	._change_state(state_name)

func _input(event):
	current_state.handle_input(event)

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	._on_animation_finished(old_name)
