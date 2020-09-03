extends baseFSM

func onChangeState(state_name):
	print("furball changing to ", state_name) # debugging
	.onChangeState(state_name)

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	._on_animation_finished(old_name)
