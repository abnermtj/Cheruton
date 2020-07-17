extends baseFSM

func _change_state(state_name):
	if not _active:
		return

	if states_stack:
		previous_state = states_stack[-1]

	if ["jump", "fall", "attack"].has(state_name):
		owner.on_floor = false
	else:
		owner.on_floor = true

#	print("player changing to ", state_name)
	._change_state(state_name)

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	._on_animation_finished(old_name)
