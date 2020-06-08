extends Enemy

onready var fsm = FSM_Enemy.new(self, $States, $States/Bob, false)

var anim_current = ""
var anim_next = "run"

var dir_cur = 1
export(int) var dir_nxt = 1



var hit_dir : Vector2
var is_hit := false
var energy = 1



func _exit_tree():
	fsm.free()

func _physics_process(delta) -> void:
	fsm.run_machine(delta)
	
	if(anim_current != anim_next):
		anim_current = anim_next
		#$Animation.play(anim_current)
	
	if (dir_cur != dir_nxt):
		dir_cur = dir_nxt
		$Rotate.scale.x = dir_cur
	
	


func check_wall() -> bool:
	if find_node( "ray_down" ):
		if not $Rotate/RayDown.is_colliding() or \
			$Rotate/RayFront.is_colliding():
				return true
	else:
		if $Rotate/RayFront.is_colliding():
			return true
	return false


#func force_jump() -> void:
#	fsm.state_nxt = fsm.states.jump
#	$damagebox/damage_collision.disabled = true
#	$jumpbox/jumpcollision.disabled = true


func _on_hitbox_area_entered(area):
	if is_hit: return
	is_hit = true
	#if fsm.state_cur == fsm.states.dead: return
	#print( "slime hit" )
	#$Animation.stop()
	hit_dir = global_position - area.global_position
	energy -= 1
	if energy > 0:
		fsm.state_nxt = fsm.states.hit
	else:
		if filename.find( "cave_slime" ) != -1:
			fsm.state_nxt = fsm.states.cave_dead
		else:
			fsm.state_nxt = fsm.states.dead

func _on_jumpbox_area_entered( _area ):
	if is_hit: return
	if fsm.state_cur == fsm.states.hit or fsm.state_nxt == fsm.states.hit or \
		fsm.state_cur == fsm.states.dead or fsm.state_nxt == fsm.states.dead or \
		( fsm.states.has( "jump" ) and fsm.state_cur == fsm.states.jump ):
			return
	fsm.state_nxt = fsm.states.jump
	anim_next = ""
	pass # Replace with function body.
	
#func hit( area, hit_energy : float = 1.0 ):
#	if fsm.state_cur == fsm.states.dead: return
#	$anim.stop()
#	energy -= hit_energy
#	if energy > 0:
#		fsm.state_nxt = fsm.states.hit
#		hit_dir = global_position - area.global_position
#	else:
#		fsm.state_nxt = fsm.states.dead




var is_exploding = false
func _on_detect_player_body_entered( _body ):
	if is_hit: return
	if is_exploding: return
	if randf() < 0: return
	is_exploding = true
	print( "SLIME DETECTED PLAYER" )
	#$rotate/detect_player/exploding_timer.start()
	
#func _on_exploding_timer():
#	# generate explosion
#	var x = preload( "res://enemies/slime/cave_slime_explosion.tscn" ).instance()
#	x.position = position
#	x.scale.x = dir_cur
#	get_parent().call_deferred( "add_child", x )
#
#	# die
#	fsm.state_nxt = fsm.states.cave_dead


func _on_exploding_timer_timeout():
	if is_hit: return
	#var x = preload( "res://enemies/slime/cave_slime_explosion.tscn" ).instance()
	#x.position = position
	#x.scale.x = dir_cur
	#get_parent().add_child( x )
	fsm.state_nxt = fsm.states.cave_dead
