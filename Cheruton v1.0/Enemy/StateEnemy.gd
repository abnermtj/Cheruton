extends Node
class_name State_Enemy

var fsm = null
#var node = null
var obj = null

func initalize():
	pass

func terminate():
	pass

func run(_delta):
	pass

func should_fall() -> void:
	if(!obj.get_node("Rotate/RayGround").is_colliding()):
		fsm.state_next = fsm.states.Fall

func aerial_pos_edit() -> void:
	#print(abs(obj.pos - obj.global_position.y))
	if(abs(obj.pos - obj.global_position.y) > 20):
		obj.velocity.y = -obj.velocity.y

