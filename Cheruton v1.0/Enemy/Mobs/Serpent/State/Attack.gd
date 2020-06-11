extends State_Enemy

# ATTACK: Enemy is currently attacking the player, who is in close range

var state : int
var timer : float

var can_fire = false

var fire_dir
var player
var player_position 
var ray_cast_front
var speed = 200

func initialize():
	timer = 0.6
	#obj.anim_next = "AttackPrep"
	can_fire = true
	player = obj.get_parent().get_node("player")
	ray_cast_front = obj.get_node("Rotate/RayPlayerFront")
	


func run(delta):
	if(timer <= 0):
		obj.anim_next = "Attack"
	else: 
		timer -= delta
	player_position = player.global_position
	# Position of player not in direction enemy is facing
	if(player_position.x >= obj.global_position.x && obj.dir_curr < 0 ||player_position.x < obj.global_position.x && obj.dir_curr > 0):
		obj.dir_next = -obj.dir_curr
	# Player has reached area enemy cannot reach
	if (obj.change_patrol_dirn()):
		speed = 0
	elif(speed < 200): 
		speed *= 3
	# Another enemy in front of original enemy
	if(ray_cast_front.is_colliding()):
		print(true)
		speed /= 2
	obj.velocity.x = obj.dir_curr * speed
	obj.velocity.y = 0#min(obj.velocity.y + 500 * _delta, 160)
	obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
	if(can_fire):
		can_fire = false
#		var speed = 0
#		fire_dir = (obj.get_angle_to(player_position/3.14))* 180
		#obj.get_node("Rotate").rotation = obj.get_angle_to(player_position)
		#load and instance skill, give its properties and add it as a child of its parent
		yield(get_tree().create_timer(0.8), "timeout")
		can_fire = true
#		speed = 120
# case for player death!
func terminate():
	can_fire = false
#
	
