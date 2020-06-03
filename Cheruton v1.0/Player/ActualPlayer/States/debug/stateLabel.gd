extends Label

var start_position = Vector2()

func _ready():
	start_position = rect_position

func _physics_process(delta):
	text = str(owner.velocity)

func _on_states_state_changed(states_stack):
	pass

