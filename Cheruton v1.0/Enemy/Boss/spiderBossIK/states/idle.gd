extends baseState

func enter():
	pass

func update(delta):
	if owner.player_found:
		emit_signal("finished", "run")

func exit():
	pass
