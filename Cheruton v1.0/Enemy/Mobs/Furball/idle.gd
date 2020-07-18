extends baseState

func enter():
	var player_obj = owner.attack_area.get_overlapping_bodies()
	if player_obj:
		emit_signal("finished", "attack")
	elif owner.return_to_sleep and (owner.global_position - owner.initial_pos).length() < 10:
		emit_signal("finished", "sleep")
	else:
		emit_signal("finished", "jump")
