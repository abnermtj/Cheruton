extends baseState

func enter():
	owner.set_anim_speed(.66)
	owner.play_anim("idle")
	owner.queue_anim("idle_continious")

	owner.velocity = Vector2()
	owner.move()

func update_idle(delta):
	if DataResource.temp_dict_player.dialog_complete && get_parent().isInputEnabled:
		emit_signal("changeState", "idle")

func exit():
	owner.talk_cooldown_start()
