extends State_Enemy

# FALL: Enemy is currently falling

const GRAVITY = 981
var state : int
var timer : float

var ray_ground

func initialize():
	obj.anim_next = "Patrol"
	ray_ground = obj.get_node("Rotate/RayGround")
	obj.velocity.x = 0

func run(delta):
	obj.velocity.y =-99999999999999999999
	print(obj.velocity.y)
	if(ray_ground.is_colliding()):
		if(fsm.state_prev):
			fsm.state_next = fsm.state_prev
		else:
			fsm.state_next = fsm.states.Patrol
		
	
func terminate():
	obj.velocity.y = 0
#
	
