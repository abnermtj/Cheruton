# Collection of important methods to handle direction and animation
extends baseState
class_name motionState

func handle_input(event):
	if event.is_action_pressed("hook")  and get_parent().current_state != get_parent().states_map["hook"]:
		owner.play_sound("hook_start")
		owner.hook_dir = get_input_direction()
		if not owner.hook_dir:
			owner.hook_dir = owner.look_direction
		owner.start_hook()


	if get_parent().current_state != get_parent().states_map["attack"] and event.is_action_pressed("attack") and owner.exit_slide_blocked == false:
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
		owner.body_sprite.flip_h = true if direction.x == -1 else false # flips horizontally

