extends State_Enemy

# FALL: Enemy is currently falling

const GRAVITY = 981
var state : int
var timer : float

var ray_ground

func initialize():
	obj.velocity.x = 0
	obj.velocity.y = 10000
	obj.anim_next = "Patrol"
	ray_ground = obj.get_node("Rotate/RayGround")

	timer = 2

func run(delta):
	if(ray_ground.is_colliding()):
		if(fsm.state_prev):
			fsm.state_next = fsm.state_prev
		else:
			fsm.state_next = fsm.states.Patrol
	else:
		obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
		
	
func terminate():
	obj.velocity.y = 0
#
	
