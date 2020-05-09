extends motionState
class_name groundState

var speed = 0.0
var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed("jump"):
		#print("jump")
		emit_signal("finished", "jump")
	return .handle_input(event) # everything below here not dealt twith
