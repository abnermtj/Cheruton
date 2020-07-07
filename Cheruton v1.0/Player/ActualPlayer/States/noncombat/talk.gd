extends baseState

func enter():
	owner.play_anim("idle")
	owner.queue_anim("idle_continious")
	owner.set_anim_speed(.66)

	owner.velocity = Vector2()
	owner.move()

func update_idle(delta):
	if DataResource.temp_dict_player.dialog_complete == true:
		emit_signal("finished", "idle")

func exit():
	owner.talk_cooldown_start()
