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
	should_fall()
	pass

func should_fall():
	if(obj.get_node("Rotate/RayGround").is_colliding()):
		fsm.state_next = fsm.states.Fall

func aerial_pos_edit():
	if(abs(obj.pos - obj.global_position.y) > 418):
		print(100110001)
		
		obj.velocity.y = -obj.velocity.y

