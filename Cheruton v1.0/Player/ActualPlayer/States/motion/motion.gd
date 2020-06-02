# Collection of important methods to handle direction and animation
extends baseState
class_name motionState

func handle_input(event):
	if Input.is_action_just_pressed("hook") and not ["slide"].has(get_parent().current_state.name): # not currently sliding
		if owner.can_hook and not owner.hooked:
			owner.play_sound("hook_start")
			owner.play_and_return_anim("grapple_throw")
			owner.hook_dir = get_input_direction()
			if owner.near_grapple_post:
				owner.hook_dir = owner.nearest_grapple_post_pos - owner.global_position
			elif not owner.hook_dir: #if not set
				owner.hook_dir = owner.look_direction
			owner.start_hook()
		elif owner.hooked:
			owner.chain_release()
			emit_signal("finished", "fall")
	elif event.is_action_pressed("attack")\
	 and not ["hook", "attack", "slide"].has(get_parent().current_state.name)\
	 and owner.can_attack:
		owner.can_attack = false
		owner.start_attack_cool_down()
		emit_signal("finished", "attack")



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
