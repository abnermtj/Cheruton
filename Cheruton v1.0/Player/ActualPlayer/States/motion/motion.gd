# Collection of important methods to handle direction and animation
extends baseState
class_name motionState

func handle_input(event):
	if event.is_action_pressed("attack")\
	 and not ["hook", "attack", "slide"].has(get_parent().current_state.name)\
	 and owner.can_attack:
		owner.can_attack = false
		owner.start_attack_cool_down()
		emit_signal("finished", "attack")
	if event.is_action_pressed("sword_throw"):
		if owner.can_throw_sword:
			owner.throw_sword_dir = get_input_direction().normalized()
			if owner.throw_sword_dir == Vector2():
				owner.throw_sword_dir = owner.look_direction
			owner.start_sword_throw()
		elif owner.sword_stuck:
			owner.return_sword_throw()
	if event.is_action_pressed("dash") and owner.can_dash:
		emit_signal("finished", "dash")




# note left and right at the same time cancel out
func get_input_direction():
	var input_direction = Vector2()
	input_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input_direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input_direction

# makes character face right direction
func update_look_direction(direction):
	if direction and owner.look_direction != direction:
		owner.look_direction = direction
	if direction.x in [-1, 1]:
		owner.body_rotate.scale = Vector2(direction.x,1) # flips horizontally
