extends Label

func _process(delta):
	text = owner.cur_state.name
