extends baseState

const RETURN_SPEED = 100
func enter():
	pass

func update(delta):
	if owner.player_found:
		emit_signal("finished", "run")
	owner.velocity = (owner.start_pos - owner.global_position).normalized() * RETURN_SPEED
	owner.move()

func exit():
	pass
