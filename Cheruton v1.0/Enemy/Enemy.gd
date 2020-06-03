extends KinematicBody2D

onready var hp_bar
onready var player = get_parent().get_node("player")

var max_HP = 400#stub
var curr_HP
var percent_HP
var can_heal = true
var is_dead = false
var state = "Ignore"

var player_nearby
var player_spotted


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
				pass
			"Follow":
				pass
			"Attack":
				print("BamBAM")


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

func _physics_process(delta):
	LOSCheck()
	pass
	
func _on_Sight_body_entered(body):
	if body == player:
		player_nearby = true
		print("player_N" + str(player_nearby))
	
func _on_Sight_body_exited(body):
	if body == player:
		player_nearby = false
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
				player_spotted = true
				state = "Attack"
			else:
				print(3)
				player_spotted = false
				state = "Ignore" #Stub	
