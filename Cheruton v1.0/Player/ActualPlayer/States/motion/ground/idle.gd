extends groundState

func enter():
	owner.get_node("AnimationPlayer").play("idle")

func handle_input(event):
	return .handle_input(event)

func update(delta):
	 # move and slide with snap incase moving platform next time
	owner.velocity = owner.move_and_slide( Vector2.ZERO, Vector2.UP)
	# we still move so we can use is_on_floor
	if not owner.is_on_floor():
		emit_signal("finished","fall")
	var input_direction = get_input_direction()
	if input_direction.x:
		emit_signal("finished", "run")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "idle":
		owner.get_node("AnimationPlayer").play("idle_continious")
