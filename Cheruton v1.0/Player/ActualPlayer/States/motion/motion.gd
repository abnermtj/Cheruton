extends baseState
class_name motionState

func handle_input(event):
	if event.is_action_pressed("attack")\
	and not ["hook", "attack", "slide", "wallSlide"].has(owner.cur_state.name)\
	and owner.can_attack\
	and owner.sword_state == owner.SWORD_STATES.ON_HAND\
	and owner.attack_enabled:
		owner.start_attack_cool_down()
		emit_signal("finished", "attack")

	elif event.is_action_pressed("throw"):
		if not ["attack", "wallSlide"].has(owner.cur_state.name)\
		and owner.sword_state == owner.SWORD_STATES.ON_HAND:
			owner.throw_sword_dir = (get_viewport().get_mouse_position() - owner.get_global_transform_with_canvas().origin).normalized()

			if owner.throw_sword_dir == Vector2(): owner.throw_sword_dir = owner.look_direction
			owner.start_sword_throw()

		elif owner.sword_state == owner.SWORD_STATES.STUCK:
			owner.return_sword_throw()

	elif event.is_action_pressed("dash") and owner.sword_state == owner.SWORD_STATES.STUCK:
		emit_signal("finished", "dash")

# note left and right at the same time cancel out
func get_input_direction():
	if get_parent().input_enabled == false: return Vector2()

	var input_direction = Vector2()
	input_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input_direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input_direction
