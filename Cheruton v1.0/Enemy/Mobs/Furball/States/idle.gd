extends baseState

func enter():
	var player_obj = owner.attack_area.get_overlapping_bodies()

	if player_obj:
		emit_signal("changeState", "attack")
	elif owner.return_to_default:
		if not owner.patrolling and (owner.global_position - owner.initial_pos).length() < 10:
			emit_signal("changeState", "sleep")
			return
		elif owner.patrolling and sign(owner.global_position.x - owner.initial_pos.x) == owner.flip_patrol_end:
			owner.flip_patrol_end = -owner.flip_patrol_end
		emit_signal("changeState", "jump")
	else:
		emit_signal("changeState", "jump")
