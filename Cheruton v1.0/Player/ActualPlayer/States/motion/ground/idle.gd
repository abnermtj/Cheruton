extends groundState

func handle_input(event):
	return .handle_input(event)

func enter():
	if not owner.prev_state or owner.prev_state.name != "talk":
		owner.set_anim_speed(.66)
		owner.play_anim("idle")
		owner.queue_anim("idle_continious")

func update(delta):
	owner.velocity = Vector2.DOWN * 10  # DOWN so we have collision response
	owner.move()

	if get_input_direction().x:
		emit_signal("finished", "run")
	.update(delta)

func exit():
	owner.set_anim_speed(1)
