extends baseFSM

func onChangeState(state_name):
	if not isActive:
		return

	if statesStack:
		prevState = statesStack[-1]

	print("player changing to ", state_name)
	.onChangeState(state_name)

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	._on_animation_finished(old_name)

func _input(event):
	._input(event)
