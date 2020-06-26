extends State_Enemy

# SEARCH: Enemy is looking actively for the player

var timer : float
var speed = 160
var player

func initialize():
	player = obj.get_parent().get_node("player")
	timer = randomize_timer()



func run(delta):
	#print(30000001)
	should_fall()
	timer -= delta
	# Enemy has encountered wall or empty gap - wait for player to come back
	if (obj.change_patrol_dirn()):
		speed = 0
	else: 
		speed = 200
	obj.velocity.x = obj.dir_curr * speed
	obj.velocity.y = 0#min(obj.velocity.y + 500 * _delta, 160)
	obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
	# Player cannot be found while search is still going on
	if (timer <= 0 && fsm.state_curr == fsm.states.Search):
		fsm.state_next = fsm.states.Patrol

# Randomize time taken by enemy to decide when to return to normal patrolling
func randomize_timer():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var my_random_number = rng.randf_range(2.4, 5.0)	
	return my_random_number

