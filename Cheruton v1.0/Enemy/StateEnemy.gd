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

func should_fall():
	if(obj && !obj.get_node("Rotate/RayGround").is_colliding()):
		fsm.state_next = fsm.states.Fall

