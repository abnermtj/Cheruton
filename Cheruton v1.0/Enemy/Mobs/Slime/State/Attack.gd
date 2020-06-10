extends State_Enemy

var state : int
var timer : float

var can_fire = false

var fire_dir
var player
var player_position 

func initialize():
	can_fire = true
	player = obj.get_parent().get_node("player")


func run(delta):
	player_position = player.global_position
	
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
	
