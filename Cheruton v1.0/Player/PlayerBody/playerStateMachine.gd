extends baseFSM

func onChangeState(state_name):
	.onChangeState(state_name)
	print("player changing from ", prevState.name, " to ", curState.name)

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	._on_animation_finished(old_name)
