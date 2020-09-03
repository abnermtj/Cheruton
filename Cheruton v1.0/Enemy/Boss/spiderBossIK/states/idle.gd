extends baseState

func enter():
	pass

func update(delta):
	if owner.player_found:
		emit_signal("changeState", "run")

func exit():
	pass
