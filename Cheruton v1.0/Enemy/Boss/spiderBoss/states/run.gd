extends baseState

const RUN_SPEED = 100
func enter():
	pass
func update(delta):
	var dir = (DataResource.dict_player.player_pos - owner.global_position).normalized()
	owner.velocity = dir * RUN_SPEED
	owner.move()

	if (DataResource.dict_player.player_pos - owner.global_position).length() < 200:
		emit_signal("finished","jumpAttack")
	.update(delta)

func exit():
	pass
