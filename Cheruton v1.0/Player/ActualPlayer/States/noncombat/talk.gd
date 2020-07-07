extends baseState

func enter():
	owner.play_anim("idle")
	owner.velocity =  Vector2()
	owner.move()

func update_idle(delta):
	if DataResource.temp_dict_player.dialog_complete == true: # tmr make temp dict by default ahve this variable
		emit_signal("finished", "idle")

func exit():
	pass
