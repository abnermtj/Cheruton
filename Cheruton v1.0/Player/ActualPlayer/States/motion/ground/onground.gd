extends motionState
class_name groundState

var speed = 0.0
var velocity = Vector2()

func handle_input(event):
	if event.is_action_pressed("jump"):
#		print ("jump")
		emit_signal("finished", "jump")
#	print(owner.is_on_floor())
	if not owner.is_on_floor():  # owner is player not parent
		emit_signal("finished","fall")

	return .handle_input(event) # everything below here not dealt twith


