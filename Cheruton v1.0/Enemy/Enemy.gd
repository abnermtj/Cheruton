extends KinematicBody2D

onready var hp_bar
onready var player = get_parent().get_node("player")
onready var map_nvg = get_parent().get_node("Navigator")


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
var start_position
var destination

var player_nearby
var player_sight
var player_spotted

signal change_health(value)



# Called when the node enters the scene tree for the first time.
func _ready():
	#$AnimationPlayer.play("state_idle")
	connect("change_health", self, "change_healthbar")
	curr_HP = max_HP
	$HealthBar.value = 100
	start_position = get_global_position()

##### State Machine #####

func _process(delta):
	if($HealthBar.value <= 50 && can_heal):
		heal_enemy()
	else:
		match state:
			"Ignore":
				print("Ignore")
				#animation = "Idle"
				pass
			"Search":
				print("Search")
				search_player(delta)
			"Return":
				print("Return")
				# Create pause to allow enemy to scan borders of search first
				#animation = "Idle"
				yield(get_tree().create_timer(3), "timeout")
				if(state == "Return"):
					return_enemy(delta)
			"Attack":
				move_enemy(delta, player.global_position, 2)
				print("Attack")
				#if(can_fire == true):
				#	attack_player()

##### Enemy Status #####

# Heal Function of enemy - customizable
func heal_enemy():
	can_heal = false
	yield(get_tree().create_timer(0.25), "timeout")
	if(!is_dead):
		var skill
		var skill_instance = skill.instance()
		skill_instance.skill_name = "Heal"
		add_child(skill_instance)
		emit_signal("change_health", 40)
		yield(get_tree().create_timer(0.25), "timeout")
		can_heal = true

# Updates healthbar of player
func change_healthbar(new_health):
	curr_HP = clamp(curr_HP + new_health, 0, 100)
	animate_healthbar($HealthBar.value, curr_HP/max_HP * 100)


# Sets color of the healthbar of enemy
func _on_HealthBar_value_changed(value):
	if(value > 49):
		$HealthBar.set_tint_progress(Color(0.180392, 0.415686, 0.258824))
	elif(value > 19):
		$HealthBar.set_tint_progress(Color(0.968627, 0.67451, 0.215686))
	else:
		$HealthBar.set_tint_progress(Color(0.768627, 0.172549, 0.211765))


func animate_healthbar(start, end):
	$TextureProgress/Tween.interpolate_property($HealthBar, "value", start, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

##### Enemy AI #####

# Enemy searches for player
func search_player(delta):
	move_enemy(delta, destination, 1.4)

func return_enemy(delta):
	move_enemy(delta, start_position, 1)

# Enemy moves to desired location
func move_enemy(delta, dest, factor):
	pass
	var dest_path = map_nvg.get_simple_path(get_global_position(), dest)
	var start_pt = get_global_position()
	var dist_travel = speed * delta

	#Implement navigation2d first!
	for point in range(dest_path.size()):
		var next_pt_dist = start_pt.distance_to(dest_path[0])
		if(dist_travel <= next_pt_dist):
			var move_rotation = get_angle_to(start_pt.linear_interpolate(dest_path[0], dist_travel/next_pt_dist))
			var motion = Vector2(speed, 0).rotated(move_rotation)
			#animation = "Walk"
			move_and_slide(motion* factor)
			break
		#Moves to next point - this point is taken as the new start point
		dist_travel -= next_pt_dist
		start_pt = dest_path[0]
		dest_path.remove(0)

	if(dest_path.size() == 0):
		# State: Return
		if(state == "Return"):
			state = "Ignore"
		# State: Search
		elif(state != "Attack"):
			player_nearby = false
			if(get_global_position() == start_position):
				state = "Ignore"
				#animation = Idle
			else:
				state = "Return"
				

func attack_player():
	can_fire = false
	speed = 0
	fire_dir = (get_angle_to(player_position/3.14))* 180
	$TurnAxis.rotation = get_angle_to(player_position)
	#load and instance skill, give its properties and add it as a child of its parent
	yield(get_tree().create_timer(0.8), "timeout")
	can_fire = true
	speed = 120

func should_set_ignore():
	if(get_global_position() != start_position):
		state = "Return"
	else:
		state = "Ignore"

func _physics_process(delta):
	LOSCheck()

# Player has entered enemies guard radius
func _on_Sight_body_entered(body):
	if body == player:
		player_nearby = true


# Player has exited enemies guard radius
func _on_Sight_body_exited(body):
	if body == player:
		player_nearby = false
		if(player_spotted):
			state = "Search"


#Checks if the player is close enough to be attacked
func LOSCheck():
	if player_nearby == true:
		var space_state = get_world_2d().direct_space_state
		var LOSight_id = space_state.intersect_ray(global_position, player.global_position, [self], 2)

		if LOSight_id:
			print(LOSight_id.collider.name)
			if (LOSight_id.collider.name == "player"):
				player_sight = true
				player_spotted = true
				player_position = player.get_global_position()
				destination = map_nvg.get_closest_point(player_position)
				state = "Attack"
			else:
				player_sight = false
				if(player_spotted):
					state = "Search"
				else:
					should_set_ignore()
