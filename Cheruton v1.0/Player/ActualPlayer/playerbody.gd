extends KinematicBody2D

# only put consts used by multiple states, no need to get owner each time
const GRAVITY = 2400
const AIR_ACCEL = 23.5  # increase in this >> increase in stearing power in air
const MAX_WIRE_LENGTH_GROUND = 1000
const INPUT_AGAIN_MARGIN = 0.12
var velocity = Vector2()

var tip_pos = Vector2()
var previous_position
var hook_dir = Vector2()
var hooked
var has_jumped = false
var on_floor = false setget signal_on_floor
var look_direction = Vector2(1, 0) setget set_look_direction
var exit_slide_blocked = false
var wall_direction = 0
var bounce_boost = false
var can_attack = true
var can_hook = true
var rope_length = 0.0
var previous_anim
var vec_to_ground = Vector2()
#var near_grapple_post = false
var can_dash = true
var nearest_grapple_post_pos = Vector2()
var is_between_tiles = true
var jump_again = false
var general_input_again = false

onready var animation_player = $AnimationPlayer
onready var animation_player_fx = $AnimationPlayerFx
onready var left_wall_raycasts = $wallRaycasts/leftSide
onready var right_wall_raycasts = $wallRaycasts/rightSide
onready var corner_correction_raycast_left = $cornerCorrectionRaycasts/leftside
onready var corner_correction_raycast_right = $cornerCorrectionRaycasts/rightside
onready var almost_reaching_platform_jump_boost = $almostReachingPlatformBoost
onready var floor_raycast = $floorRay
onready var sound_parent = $sounds
onready var body_rotate = $bodyPivot/bodyRotate
onready var arm_rotate = $bodyPivot/armSprite
onready var body_collision = $bodyCollision
onready var slide_collision = $slideCollision
onready var states = $states

signal state_changed
signal hook_command
signal camera_command
signal shake

func take_damage(attacker, amount, effect=null):
	if is_a_parent_of(attacker):
		return
	$States/Stagger.knockback_direction = (attacker.global_position - global_position).normalized()
	$Health.take_damage(amount, effect)
func set_dead(value): # non zero means dead
	set_process_input(not value)
	set_physics_process(not value)
	$CollisionPolygon2D.disabled = value

func _physics_process(delta):
	previous_position = global_position # needs to be under physics# parent physcis happens before children
	if floor_raycast.is_colliding():
		vec_to_ground = global_position - floor_raycast.get_collision_point()

# General Helper functions
func set_look_direction(value): # vector
	look_direction = value
func _on_states_state_changed(states_stack):
	emit_signal("state_changed", states_stack)
func signal_on_floor(grounded):
	on_floor = grounded
	set_camera_mode_logic()
	if grounded:
		can_dash = true

# Animation
func play_anim(string):
	if animation_player:
		if string != "previous":
			animation_player.play(string)
			previous_anim = string
		else:
			animation_player.play(previous_anim)
func queue_anim(string):
	if animation_player:
		if string != "previous":
			animation_player.queue(string)
			previous_anim = string
		else:
			animation_player.queue(previous_anim)
func play_and_return_anim(string):
	if animation_player:
		animation_player.play(string)
		animation_player.queue(previous_anim)
func stop_anim():
	if animation_player:
		animation_player.stop(false)
func play_anim_fx(string):
	if animation_player_fx:
		animation_player_fx.play(string)
func queue_anim_fx(string):
	if animation_player_fx:
		animation_player_fx.queue(string)


# Hook
func start_hook():
	emit_signal("hook_command",0, hook_dir,global_position)
	can_hook = false
	$grappleCoolDown.start(.5)
func _on_grappleCoolDown_timeout():
	can_hook = true
func _on_Chain_hooked(command, tip_p):
	if command == 0:
		hooked = true
		tip_pos = tip_p
		rope_length = global_position.distance_to(tip_pos) # used to limit player distance from tip
		states._change_state("hook")
		set_camera_mode_logic()
	elif command == 1: # bad hook
		play_sound("hook_bad")
func get_close_to_floor_collider():
	return floor_raycast.get_collider()
func chain_release():
	hooked = false
	emit_signal("hook_command", 1,Vector2(),Vector2())
	can_hook = false
	$grappleCoolDown.start(.05)

## grapple
#func _on_grapplePoints_grapple_command_final(command, pos):
#	if command == 0: # Near a grapple post
#		nearest_grapple_post_pos = pos
#		near_grapple_post = true
#	elif command == 1: # not near
#		near_grapple_post = false
func get_nearest_hook_point():
	var hook_points = $circleScan.get_overlapping_bodies()
	var non_blocked_hook_points = []
	var space_state = get_world_2d().direct_space_state

	for hook_point in hook_points:
		if hook_point.is_in_group("hook_points"):
			var result = space_state.intersect_ray(hook_point.position, global_position)
			if result.empty():
				non_blocked_hook_points.append( weakref(hook_point)) # don't need to duplicate

	if non_blocked_hook_points.empty():
		return

	var min_dist = INF
	var closest_hook_point = null
	for hook_point in non_blocked_hook_points:
		var cur_dist = global_position.distance_to(hook_point.position)
		# only hook to points in direction of character look
		if sign(look_direction.x) == sign(hook_point.x - global_position.x) and  min_dist > cur_dist:
			min_dist = cur_dist
			closest_hook_point = hook_point
	if closest_hook_point: return closest_hook_point

# Movement
func move():
	if hooked and not ["hook"].has(states.current_state.name) and\
	(global_position + velocity).distance_to(tip_pos) > MAX_WIRE_LENGTH_GROUND:
			move_and_slide(Vector2(), Vector2.UP)
	elif  ["run", "slide"].has(states.current_state.name):
		move_and_slide_with_snap(velocity,Vector2.DOWN * 15, Vector2.UP)
	else:
		move_and_slide(velocity, Vector2.UP)
func switch_col():
	slide_collision.disabled = not slide_collision.disabled
	body_collision.disabled = not body_collision.disabled
func _on_slideArea2D_body_exited(body):
	if not body.is_in_group("non_blocking_objects"):
		exit_slide_blocked = false
func _on_slideArea2D_body_entered(body):
	if not body.is_in_group("non_blocking_objects"):
		exit_slide_blocked = true
# wall climb
func _update_wall_direction():
	var is_near_wall_left = _is_wall_raycast_colliding(left_wall_raycasts)
	var is_near_wall_right = _is_wall_raycast_colliding(right_wall_raycasts)

	if is_near_wall_left && is_near_wall_right:
		wall_direction = wall_direction # change to get input CHANGECHANGE
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)
	if not is_near_wall_left and not is_near_wall_right:
		return false
	else:
		return true
func _is_wall_raycast_colliding(wall_raycasts):
	for raycast in wall_raycasts.get_children():
			if raycast.is_colliding():
				var angle =  acos(Vector2.UP.dot(raycast.get_collision_normal())) # this is dot product, accounts for slopes
				if  angle > deg2rad(60) &&  angle < deg2rad(120):
					return true
	return false
# a little boost to the player incase barely missing the platform above
func is_almost_at_a_platform():
	return almost_reaching_platform_jump_boost.get_overlapping_bodies()

# 1 if corner on the right -1 if left
func is_there_corner_above():
	var corner_dir = 0
	if corner_correction_raycast_left.is_colliding(): corner_dir -= 1
	if corner_correction_raycast_right.is_colliding():  corner_dir += 1
	return corner_dir
# dropdown jump
func _on_dropDownArea_body_exited(body):
	is_between_tiles = false
# jump input buffering
func jump_buffer_start():
	jump_again = true
	$jumpInputBuffer.start(INPUT_AGAIN_MARGIN)
func _on_jumpInputBuffer_timeout():
	jump_again = false
func general_buffer_start(): # exact same as above, should probably make a system for it
	general_input_again = true
	$slideInputBuffer.start(INPUT_AGAIN_MARGIN)
func _on_generalInputBuffer_timeout():
	general_input_again = false

# ATTACK
func start_attack_cool_down():
	$attackCoolDown.start(1)
func _on_attackCoolDown_timeout():
	can_attack = true

func play_sound(string):
#	sound_parent.get_node(string).play()
	pass
func stop_sound(string):
	sound_parent.get_node(string).stop()
func volume(string, vol_db):
	sound_parent.get_node(string).volume_db = vol_db

func _ready():
	body_collision.disabled = false
	slide_collision.disabled = true
	arm_rotate.visible = false

func _process(delta):
	DataResource.dict_player.player_pos = global_position  # additional vector to correct middle of player
	if hooked or not DataResource.dict_player.chain_in_air: # chain node must be above player node in scene tree
		stop_sound("hook_start")

# CAMERA  CONTROL PART
func set_camera_mode_logic():
	if hooked or states.previous_state.name == "hook":
		emit_signal("camera_command", 1, 0) # HOOK MODE
	else:
		emit_signal("camera_command", 0, on_floor) # GENERAL MODE
func shake_camera(dur, freq, amp, dir):
	emit_signal("shake", dur, freq, amp, dir)








