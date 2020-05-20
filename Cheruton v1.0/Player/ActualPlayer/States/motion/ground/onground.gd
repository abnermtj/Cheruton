extends motionState
class_name groundState

var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed("jump") and not owner.slide_blocked:
		emit_signal("finished", "jump")
	return .handle_input(event) # everything below here not dealt twith

func update(delta):
	if not owner.is_on_floor():
		emit_signal("finished","fall")

