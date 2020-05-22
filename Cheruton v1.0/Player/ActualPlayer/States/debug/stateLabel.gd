extends Label

#onready var max_vel = 0
var start_position = Vector2()

func _ready():
	start_position = rect_position

func _physics_process(delta):
#	rect_position = $"../bodyPivot".position + start_position
#	if (Input.is_action_just_pressed("ui_cancel")):
#		max_vel = 0
#	if owner.velocity.length() > max_vel:
#		max_vel = owner.velocity.length()
	text = str(owner.velocity)
#	text = str(owner.get_node("states/attack").attack_count)

func _on_states_state_changed(states_stack):
	pass
#	text = states_stack[0].get_name()

