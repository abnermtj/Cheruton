
extends KinematicBody2D

onready var hp_bar
onready var player = get_parent().get_node("player")
onready var map_nvg 


var speed = 120
var max_HP = 400#stub
var curr_HP
var percent_HP = 100
var can_fire = true
var can_heal = true
var is_dead = false
var state = "Ignore"

var fire_dir
var player_position

var player_nearby
var player_sight
var player_spotted
var dest


# Called when the node enters the scene tree for the first time.
func _ready():
	#$AnimationPlayer.play("state_idle")
	curr_HP = max_HP

func _process(delta):
	percent_HP = curr_HP/max_HP * 100
	if(percent_HP <= 50 && can_heal):
		heal_enemy()
	else:
		match state:
			"Ignore":
				#print("zzzz")
				#print("Ignored")
				pass
			"Search":
				search_player(delta)
			"Follow":
				pass
			"Attack":
				print("BamBAM")
				if(can_fire == true):
					attack_player()


func heal_enemy():
	can_heal = false
	yield(get_tree().create_timer(0.25), "timeout")
	if(!is_dead):
		var skill
		var skill_instance = skill.instance()
		skill_instance.skill_name = "Heal"
		add_child(skill_instance)
		yield(get_tree().create_timer(0.25), "timeout")
		can_heal = true

func search_player(delta):
	pass
#	#var dest_path = map_nvg.get_simple_path(get_global_position(), dest)
#	var start_pt = get_global_position()
#	var dist_travel = speed * delta
	
#Implement navigation2d first!
#for point in range(dest_path.size()):
#	var next_point_dist = start_pt.distance_to(dest_path[0])
#	if(dist_travel <= next_pt_dist):
#		var move_rotation = get_angle_to(start_pt, linear_interpolate(dest_path[0], dist_travel/next_pt))
#		var motion = Vector2(speed, 0).rotated(move_rotation)
#		move_and_slide(motion)
#		break
	#Moves to next point - this point is taken as the new start point
#	dist_travel -= next_pt_dist
#	start_pt = dest_path[0]
#	dest_path.remove(0)

func attack_player():
	can_fire = false
	speed = 0
	fire_dir = (get_angle_to(player_position/3.14))* 180
	$TurnAxis.rotation = get_angle_to(player_position)
	#load and instance skill, give its properties and add it as a child of its parent
	yield(get_tree().create_timer(0.8), "timeout")
	can_fire = true
	speed = 120
	
	
func _physics_process(delta):
	LOSCheck()
	pass
	
func _on_Sight_body_entered(body):
	if body == player:
		player_nearby = true
		print("player_Yeeee" + str(player_nearby))
	
func _on_Sight_body_exited(body):
	if body == player:
		player_nearby = false
		if(player_spotted):
			state = "Search"
		print("player_Naa" + str(player_nearby))

#Checks if the player is close enough to be attacked
func LOSCheck():
	if player_nearby == true:
		var space_state = get_world_2d().direct_space_state
		var LOSight_id = space_state.intersect_ray(position, player.position, [self], collision_mask)
		print (LOSight_id)
		print(1)
		if LOSight_id:
			print(0)
			print(LOSight_id.collider.name)
			if (LOSight_id.collider.name == "player"):
				print(2)
				player_sight = true
				player_spotted = true
				player_position = player.get_global_position()
				#dest = map_nvg.get_closest_point(player_position)
				state = "Attack"
			else:
				print(3)
				player_sight = false
				if(player_spotted):
					state = "Search"
				else:
					state = "Ignore"
