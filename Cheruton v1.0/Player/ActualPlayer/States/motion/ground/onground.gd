extends motionState
class_name groundState

var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed("jump") and not( owner.exit_slide_blocked and get_parent().current_state.name == "slide") :
		if Input.is_action_pressed("move_down"):
			owner.is_between_tiles = true
			owner.global_position.y += 1
		else:
			emit_signal("finished", "jump")
	return .handle_input(event) # everything below here not dealt twith

func update(delta):
	if not owner.is_on_floor():
		emit_signal("finished","fall")

func update_idle(delta):
	pass


