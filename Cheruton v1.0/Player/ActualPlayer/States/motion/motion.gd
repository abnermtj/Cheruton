extends baseState
class_name motionState

func handle_input(event):
	if event.is_action_pressed("attack")\
	 and not ["hook", "attack", "slide"].has(owner.cur_state.name)\
	 and owner.can_attack\
	 and owner.can_throw_sword:
		owner.can_attack = false
		owner.start_attack_cool_down()
		emit_signal("finished", "attack")
	if event.is_action_pressed("sword_throw"):
		if owner.can_throw_sword and not ["attack", "wallSlide"].has(owner.cur_state.name) : # so that cannot throw while has sword
			owner.throw_sword_dir = get_input_direction().normalized()
			if owner.throw_sword_dir == Vector2(): owner.throw_sword_dir = owner.look_direction
			owner.start_sword_throw()
		elif owner.sword_stuck:
			owner.return_sword_throw()
	if event.is_action_pressed("dash") and owner.sword_stuck:
		emit_signal("finished", "dash")

# note left and right at the same time cancel out
func get_input_direction():
	var input_direction = Vector2()
	input_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input_direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input_direction
