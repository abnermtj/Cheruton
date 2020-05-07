extends Label

var start_position = Vector2()

func _ready():
	start_position = rect_position  # memeorize start position

func _physics_process(delta):
	rect_position = $"../bodyPivot".position + start_position

func _on_states_state_changed(states_stack):
	text = states_stack[0].get_name()


#func _on_Player_state_changed(states_stack):
#	text = states_stack[0].get_name()
#
