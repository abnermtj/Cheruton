extends groundState

func enter():
	owner.play_anim("idle")
	owner.queue_anim("idle_continious")
func handle_input(event):
	return .handle_input(event)

func update(delta):
	 # change to move_and_slide_with_snap if ever using moving platforms
	owner.velocity = Vector2.DOWN  * 10  # this vector canot be just 1 unit else there may sometime be but in collision detection
	owner.move() # DOWN so we have collision response
	if not owner.is_on_floor():
		emit_signal("finished","fall")
	var input_direction = get_input_direction()
	if input_direction.x:
		emit_signal("finished", "run")
	.update(delta)
