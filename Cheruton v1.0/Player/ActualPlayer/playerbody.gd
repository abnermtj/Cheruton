extends KinematicBody2D

# Some Code Rules
# 1 - no using getNode/$ except for in the root, no owner.get_node("asd")
# 2 - use owner. or signals to tell root nodeto do something
# 3 - nested if statements MAX 3, if statements should be one liners with 3-4 conditions max
# 4 - CAPS for CONSTS,
# 5 - snake_case for variable_names and function_names
# 6 - all FileNames in PascalCase
# 7 - nodes in camelCase
# 8 - General Order of variables
######TOP of script#######
#	- Consts
# 	-  vars
#	- onready vars
#	- signals
# IMPT NOTES
# -anmation player connects to states -> ON ANIMATION CHANGED

const GRAVITY = 2400
const AIR_ACCEL = 23.5  # increase in this >> increase in stearing power in air
const MAX_WIRE_LENGTH_GROUND = 1000
const INPUT_AGAIN_MARGIN = 0.12

var cur_state : Node
var prev_state : Node
var velocity = Vector2()
var on_floor = false setget signal_on_floor
var look_direction = Vector2(1, 0) setget set_look_direction
var previous_anim : String
var is_invunerable = false

var has_jumped = false
var jump_again = false
var bounce_boost = false

var tip_pos : Vector2
var hook_dir : Vector2
var hooked : bool
var rope_length = 0.0
var nearest_hook_point
var previous_hook_point

var exit_slide_blocked = false

var wall_direction = 0 # 0 or 1

var throw_sword_dir = Vector2()
var sword_stuck = false
var sword_pos = Vector2()

var can_attack = true
var can_hook = true
var can_throw_sword = true

onready var animation_player = $animationPlayer
onready var animation_player_fx = $animationPlayerFx
onready var animation_player_fx_color = $animationPlayerFxColor
onready var left_wall_raycasts = $wallRaycasts/leftSide
onready var right_wall_raycasts = $wallRaycasts/rightSide
onready var corner_correction_raycast_left = $cornerCorrectionRaycasts/leftside
onready var corner_correction_raycast_right = $cornerCorrectionRaycasts/rightside
onready var almost_reaching_platform_jump_boost = $almostReachingPlatformBoost
onready var floor_raycast = $floorRay
onready var sound_parent = $sounds
onready var body_pivot = $bodyPivot
onready var body_rotate = $bodyPivot/bodyRotate
onready var body_collision = $bodyCollision
onready var slide_collision = $slideCollision
onready var states = $states
onready var circle_scan = $circleScan
onready var shoulder_position = $bodyPivot/bodyRotate/shoulderPosition

signal hook_command
signal flying_sword_command
signal camera_command
signal shake

func _ready():
	cur_state = states.current_state
	body_collision.disabled = false
	slide_collision.disabled = true

func _process(delta):
	DataResource.temp_dict_player.player_pos = global_position # for objects that target player, it needs to be as often as fps
	DataResource.temp_dict_player.player_shoulder_pos = shoulder_position.global_position

func _physics_process(delta):
	var old_nearest_hook_point = nearest_hook_point
#
	nearest_hook_point = get_nearest_hook_point()
	if nearest_hook_point != old_nearest_hook_point:
		if nearest_hook_point:
			nearest_hook_point.active = true # just a visual indicator
		if old_nearest_hook_point:
			old_nearest_hook_point.active = false

# General Helper functions
func set_look_direction(value : Vector2):
	look_direction = value
func _on_states_state_changed(states_stack):
	prev_state = cur_state
	cur_state = states_stack[-1]
func signal_on_floor(grounded):
	on_floor = grounded
	set_camera_mode_logic()

# Animation
func play_anim(string):
	if animation_player:
			animation_player.clear_queue()
			animation_player.play(string)
			previous_anim = string
			animation_player.advance(0)
func queue_anim(string):
	if animation_player:
			animation_player.queue(string)
			previous_anim = string
func play_and_return_anim(string):
	if animation_player:
		animation_player.play(string)
		animation_player.queue(previous_anim)
func stop_anim():
	if animation_player: animation_player.stop(false)
func set_anim_speed (val : float):
	if animation_player: animation_player.playback_speed = val
func play_anim_fx(string):
	if animation_player_fx: animation_player_fx.play(string)
func queue_anim_fx(string):
	if animation_player_fx: animation_player_fx.queue(string)

func play_anim_fx_color(string):
	if animation_player_fx_color: animation_player_fx_color.play(string)

# Grapple
func start_hook():
	emit_signal("hook_command",0, hook_dir,global_position)
	can_hook = false
	$timers/grappleCoolDown.start(.5)
func _on_grappleCoolDown_timeout():
	can_hook = true
func _on_Chain_hooked(command, tip_p, node):
	if command == 0: # good hook
		hooked = true
		tip_pos = tip_p
		previous_hook_point = node
		rope_length = global_position.distance_to(tip_pos) # used to limit player distance from tip, she can't run from it
		states._change_state("hook")
		set_camera_mode_logic()
	elif command == 1: # bad hook
		play_sound("hook_bad")
func get_close_to_floor_collider(): # used to repel player from floor
	return floor_raycast.get_collider()
func chain_release():
	hooked = false
	emit_signal("hook_command", 1,Vector2(),Vector2())
	can_hook = false
	$timers/grappleCoolDown.start(.05)

func get_nearest_hook_point():
	var near_hook_points = circle_scan.get_overlapping_bodies()
	var non_blocked_hook_points = []
	var space_state = get_world_2d().direct_space_state

#	print(near_hook_points)
	for hook_point in near_hook_points:
		if not hook_point.is_in_group("hook_points"): continue
		var result = space_state.intersect_ray(global_position + Vector2(0,-50), hook_point.global_position ,[self,hook_point], 32)
		if result.empty(): non_blocked_hook_points.append( hook_point)

	if non_blocked_hook_points.empty():
		return

	var min_dist_facing = INF
	var min_dist_opp = INF
	var closest_hook_point_facing_dir = null
	var closest_hook_point_opp_dir = null


	var facing_dir_x = sign(body_rotate.scale.x)
	# get nearest hook point in front and behind sepearately
	for hook_point in non_blocked_hook_points:
		var cur_dist = global_position.distance_to(hook_point.global_position)
		# look for hooks in the direction character faces
		if facing_dir_x == sign(hook_point.global_position.x - global_position.x) and min_dist_facing > cur_dist:
			min_dist_facing = cur_dist
			closest_hook_point_facing_dir = hook_point
		elif facing_dir_x != sign(hook_point.global_position.x - global_position.x) and min_dist_opp > cur_dist:
			min_dist_opp = cur_dist
			closest_hook_point_opp_dir = hook_point
	if closest_hook_point_facing_dir:
		return closest_hook_point_facing_dir
	elif closest_hook_point_opp_dir:
		return closest_hook_point_opp_dir

# swordThrow
func start_sword_throw():
	can_throw_sword = false
	sword_stuck = false
	emit_signal("flying_sword_command", 0, throw_sword_dir)
func return_sword_throw():
	sword_stuck = false
	emit_signal("flying_sword_command", 1, Vector2())
func on_sword_result(result, pos):
	if result == 0: # hit
		sword_stuck = true
		sword_pos = pos
	elif result == 1: # returning
		sword_stuck = false
	elif result == 2:
		can_throw_sword = true
		sword_stuck = false
# player damaged
func _on_hitBox_area_entered(area):
	if is_invunerable: return

	if hooked: chain_release()

	var hit_dir = global_position - area.global_position
	velocity = hit_dir.normalized() * 400
	move()
	states._change_state("hit")

func set_player_invunerable(time):
	is_invunerable = true
	$timers/invunerableTimer.start(time)
func _on_invunerableTimer_timeout():
	is_invunerable = false

# Movement
func move():
	if hooked and not ["hook"].has(cur_state.name) and\
	(global_position + velocity).distance_to(tip_pos) > MAX_WIRE_LENGTH_GROUND: # player cannot move too far from hook point
			move_and_slide(Vector2(), Vector2.UP)
	elif  ["run", "slide", "idle", "wallSlide"].has(cur_state.name):
		move_and_slide_with_snap(velocity,Vector2.DOWN * 15, Vector2.UP)
	else:
		move_and_slide(velocity, Vector2.UP)

	for i in get_slide_count():
		var col = get_slide_collision(i)
		if col.collider.has_method("handle_collision"): # used to hit enemies / platform
			col.collider.handle_collision(col, self)


func switch_col():
	slide_collision.disabled = not slide_collision.disabled
	body_collision.disabled = not body_collision.disabled
func _on_slideArea2D_body_exited(body):
	if not body.is_in_group("one_way_platforms"):
		exit_slide_blocked = false
func _on_slideArea2D_body_entered(body):
	if not body.is_in_group("one_way_platforms"):
		exit_slide_blocked = true

# wall climb
func get_wall_direction():
	var is_near_wall_left = _is_wall_raycast_colliding(left_wall_raycasts)
	var is_near_wall_right = _is_wall_raycast_colliding(right_wall_raycasts)

	if is_near_wall_left and is_near_wall_right:
		wall_direction = sign(velocity.x)
		if not wall_direction: wall_direction = -look_direction.x
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)

	return wall_direction

func _is_wall_raycast_colliding(wall_raycasts) -> bool:
	for raycast in wall_raycasts.get_children():
			if raycast.is_colliding():
				var angle =  abs(acos(Vector2.UP.dot(raycast.get_collision_normal()))) #accounts for slopes
				if  angle > deg2rad(60) &&  angle < deg2rad(120):
					return true
	return false

# a y boost to the player incase barely missing the platform above
func is_almost_at_a_platform():
	return almost_reaching_platform_jump_boost.get_overlapping_bodies()
# 1 if corner on the right -1 if left, used to nudge player away from smashing corners
func is_there_corner_above():
	return int (corner_correction_raycast_right.is_colliding()) - int(corner_correction_raycast_left.is_colliding())

# jump input buffering
func jump_buffer_start():
	jump_again = true
	$timers/jumpInputBuffer.start(INPUT_AGAIN_MARGIN)
func _on_jumpInputBuffer_timeout():
	jump_again = false

# ATTACK
func start_attack_cool_down():
	$timers/attackCoolDown.start(1)
func _on_attackCoolDown_timeout():
	can_attack = true

#Sound
func play_sound(string):
#	sound_parent.get_node(string).play()
	pass
func stop_sound(string):
	sound_parent.get_node(string).stop()
func volume(string, vol_db):
	sound_parent.get_node(string).volume_db = vol_db

# CAMERA  CONTROL PART
func set_camera_mode_logic():
	if hooked or states.previous_state.name == "hook":
		emit_signal("camera_command", 1, 0) # HOOK MODE
	else:
		emit_signal("camera_command", 0, on_floor) # GENERAL MODE
func shake_camera(dur, freq, amp, dir):
	emit_signal("shake", dur, freq, amp, dir)


func handle_enemy_attack_collision(damage):
	#DataResource.change_health(damage)
	print("Player hit!")

