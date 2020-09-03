extends Label

var prev
func _physics_process(delta):
#	text = shysics_process(delta):
#	text = str(owner.velocity)
#	text = str(owner.sword_state, owner.can_attack, owner.attack_cooldown_finished)
	text = owner.cur_state.name
#	text = str(owner.can_attack, owner.attack_count)
#	if owner.attack_count != prev:
#
#		print(owner.attack_count)
#		prev = owner.attack_count


#func _on_states_stateChanged(statesStack):
#	pass

