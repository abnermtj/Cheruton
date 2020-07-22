extends motionState
class_name groundState

var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed("jump") and not( owner.exit_slide_blocked and owner.cur_state.name == "slide") :
		if Input.is_action_pressed("move_down"):
			owner.global_position.y += 1
		else:
			emit_signal("finished", "jump")

	if event.is_action_pressed("interact"):
		if owner.interaction_type == "dialog" and owner.can_talk:
			DataResource.temp_dict_player.dialog_complete = false
			owner.interact_with_nearest_object()
			emit_signal("finished", "talk")
		else:
			owner.interact_with_nearest_object()

	return .handle_input(event) # everything below here not dealt twith

func update(delta):
	if not owner.is_on_floor():
		emit_signal("finished","fall")


