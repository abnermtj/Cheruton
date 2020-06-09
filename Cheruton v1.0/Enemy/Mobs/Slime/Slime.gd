extends Enemy

onready var fsm = FSM_Enemy.new(self, $States/Search, false)
onready var initial_position = global_position
onready var player = get_parent().get_node("player")
onready var healthbar = $HealthBar
onready var healthbar_act = $HealthBar/HealthRect/HealthBar

var anim_curr = ""
var anim_next = "run"

var dir_curr = 1
export(int) var dir_next = 1

var velocity = Vector2()

var hit_dir : Vector2
var is_hit := false
var energy = 1

var curr_health
var max_health

var player_nearby
var player_sight
var player_spotted

func _ready():
	max_health = 150
	curr_health = max_health
	healthbar.initbar(max_health)


func _exit_tree():
	fsm.call_deferred("free")

func _physics_process(delta) -> void:
	fsm.run_machine(delta)

	if(anim_curr != anim_next):
		anim_curr = anim_next
		#$Animation.play(anim_current)
	
	if (dir_curr != dir_next):
		dir_curr = dir_next
		$Rotate.scale.x = dir_curr
	
	

# Checks if the node is colliding against a wall or is reaching the edge of his path
func change_patrol_dirn() -> bool:
	if ($Rotate/RayFront.is_colliding() || !$Rotate/RayDown.is_colliding()):
		return true
	return false


#func force_jump() -> void:
#	fsm.state_nxt = fsm.states.jump
#	$damagebox/damage_collision.disabled = true
#	$jumpbox/jumpcollision.disabled = true

# Slime has been hit
func _on_HitBox_area_entered(area):
	# Damage processed if the node has not been previously hit or not dead
	if (!is_hit):
		is_hit = true
		#$Animation.stop()
		hit_dir = global_position - area.global_position
		var damage = -40#stub
		# Enemy will die
		if(abs(damage) > curr_health):
			pass
			fsm.state_next = fsm.states.Dead
		else:
			curr_health += damage
			fsm.state_next = fsm.states.Hit
		healthbar.animate_healthbar(healthbar_act.value, healthbar_act.value + damage)



#func _on_JumpBox_area_entered(_area):
#	if (!is_hit):
#		if fsm.state_cur == fsm.states.hit or fsm.state_nxt == fsm.states.hit or \
#			fsm.state_cur == fsm.states.dead or fsm.state_nxt == fsm.states.dead or \
#			( fsm.states.has( "jump" ) and fsm.state_cur == fsm.states.jump ):
#				return
#		fsm.state_nxt = fsm.states.jump
#		anim_next = ""
#		pass # Replace with function body.
	
#func hit( area, hit_energy : float = 1.0 ):
#	if fsm.state_cur == fsm.states.dead: return
#	$Animation.stop()
#	energy -= hit_energy
#	if energy > 0:
#		fsm.state_nxt = fsm.states.hit
#		hit_dir = global_position - area.global_position
#	else:
#		fsm.state_nxt = fsm.states.dead




#var is_exploding = false
#func _on_detect_player_body_entered( _body ):
#	if is_hit: return
#	if is_exploding: return
#	if randf() < 0: return
#	is_exploding = true
#	print( "SLIME DETECTED PLAYER" )
#	pass
#	#$rotate/detect_player/exploding_timer.start()
	
#func _on_exploding_timer():
#	# generate explosion
#	var x = preload( "res://enemies/slime/cave_slime_explosion.tscn" ).instance()
#	x.position = position
#	x.scale.x = dir_cur
#	get_parent().call_deferred( "add_child", x )
#
#	# die
#	fsm.state_nxt = fsm.states.cave_dead

#
#func _on_exploding_timer_timeout():
#	pass
#	#if is_hit: return
#	#var x = preload( "res://enemies/slime/cave_slime_explosion.tscn" ).instance()
#	#x.position = position
#	#x.scale.x = dir_cur
#	#get_parent().add_child( x )
#	#fsm.state_nxt = fsm.states.cave_dead



# Player has entered enemies guard radius
func _on_AOSBox_body_entered(body):
	if (body == player):
		pass
		#fsm.state_next = fsm.states.Attack

# Player has left enemies guard radius
func _on_AOSBox_body_exited(body):
	if (body == player):
		fsm.state_next = fsm.states.Search

