extends State_Enemy

# ATTACK: Enemy is currently attacking the player, who is in close range
onready var attack_instance = preload("res://Enemy/Mobs/Slime/Attack/SlimeRange.tscn")

var state : int
var timer : float

var can_fire = false

var fire_dir
var player
var player_position 
var ray_cast_front
var speed = 200

func initialize():
	can_fire = true
	player = obj.get_parent().get_node("player")
	ray_cast_front = obj.get_node("Rotate/RayPlayerFront")
	


func run(delta):
	should_fall()
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
		speed /= 4
	obj.velocity.x = obj.dir_curr * speed
	obj.velocity.y = 0#min(obj.velocity.y + 500 * _delta, 160)
	obj.velocity = obj.move_and_slide_with_snap(obj.velocity, Vector2.DOWN * 8, Vector2.UP)
	if(can_fire):
		can_fire = false
		var speed_attack = 200
		var instanced = attack_instance.instance()
		obj.add_child(instanced)
		obj.get_child(obj.get_child_count() - 1).velocity.x = speed_attack * obj.dir_curr
#		load and instance skill, give its properties and add it as a child of its parent
		yield(get_tree().create_timer(0.8), "timeout")
		can_fire = true
#		speed = 120
# case for player death!
func terminate():
	can_fire = false
#
	
