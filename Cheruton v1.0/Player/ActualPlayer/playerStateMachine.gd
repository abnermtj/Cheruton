extends baseFSM

func _change_state(state_name):
	if not _active:
		return

	if states_stack:
		previous_state = states_stack[-1]

	print("player changing to ", state_name)
	._change_state(state_name)

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	._on_animation_finished(old_name)

func _input(event):
	._input(event)
