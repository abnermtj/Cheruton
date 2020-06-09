extends State_Enemy

var state : int
var timer : float

var player
var ray_cast_front
var ray_cast_back

func initialize():
	fix_locations()
	timer = randomize_timer()
	obj.anim_next = "patrol"#seacrh



func run(delta):
	timer -= delta
	if(ray_cast_front.get_collider == player):
		ray_cast_front.get_collision_point()
	elif(ray_cast_back.get_collider == player):
		ray_cast_back.get_collision_point()
		
	# Provided the player cannot be found in time
	if (timer <= 0 && fsm.state_curr == fsm.states.Search):
		fsm.state_next = fsm.states.Patrol


func terminate():
	pass

func randomize_timer():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var my_random_number = rng.randf_range(2.4, 5.0)	
	return my_random_number

func fix_locations():
	player = obj.get_parent().get_node("player")
	ray_cast_front = obj.get_node("Rotate/RayPlayerFront")
	ray_cast_back = obj.get_node("Rotate/RayPlayerBack")
