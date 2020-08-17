extends Label

func _process(delta):
#	text = owner.cur_state.name
	text = str(owner.velocity.y)
