extends Node

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("jump"):
		find_node("Camera2D").shake(.2, 15, 1) # time frequency amplitude
	if Input.is_action_pressed("move_up"):
		find_node("Camera2D").pan_camera(Vector2(0,-200)) # time frequency amplitude
	else:
		find_node("Camera2D").pan_camera(Vector2(0,0))


