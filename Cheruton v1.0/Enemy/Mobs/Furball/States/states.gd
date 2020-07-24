extends baseFSM

func _change_state(state_name):
#	print("furball changing to ", state_name) # debugging
	._change_state(state_name)

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	._on_animation_finished(old_name)
