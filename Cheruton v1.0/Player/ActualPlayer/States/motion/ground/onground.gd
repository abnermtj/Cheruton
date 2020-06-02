extends motionState
class_name groundState

var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed("jump") and not( owner.exit_slide_blocked and get_parent().current_state.name == "slide") :
		if event.is_action_pressed("ui_down"):
			emit_signal("finished", "jump_down")
		else:
			emit_signal("finished", "jump")
	return .handle_input(event) # everything below here not dealt twith

func update(delta):
	if not owner.is_on_floor():
		emit_signal("finished","fall")

func update_idle(delta):
	pass


