extends groundState

func handle_input(event):
	.handle_input(event)

func enter():
	if not owner.prev_state or owner.prev_state.name != "talk":
		owner.set_anim_speed(.66)
		owner.play_anim("idle")
		owner.queue_anim("idle_continious")

func update(delta):
	owner.velocity = Vector2.DOWN * 12  # DOWN so we have collision response, to check if need to fall
	owner.move()

	if get_input_direction().x:
		emit_signal("changeState", "run")

	.update(delta)

func exit():
	owner.set_anim_speed(1)
