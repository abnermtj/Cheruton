extends State_Enemy


var timer : float
var speed = 160
var player
var ray_cast_back

func initialize():
	fix_locations()
	timer = randomize_timer()



func run(delta):
	timer -= delta
	var collision_pt
	if(ray_cast_back.get_collider() == player):
		obj.dir_next = -obj.dir_curr
	if (obj.change_patrol_dirn()):
		speed = 0
	else: 
		speed = 200
	obj.velocity.x = obj.dir_curr * speed
	obj.velocity.y = 0#min(obj.velocity.y + 500 * _delta, 160)
	obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
	# Provided the player cannot be found in time
	if (timer <= 0 && fsm.state_curr == fsm.states.Search):
		fsm.state_next = fsm.states.Patrol


func randomize_timer():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var my_random_number = rng.randf_range(2.4, 5.0)	
	return my_random_number

func fix_locations():
	player = obj.get_parent().get_node("player")
	ray_cast_back = obj.get_node("Rotate/RayPlayerBack")
