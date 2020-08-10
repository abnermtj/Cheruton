extends KinematicBody2D
# IMPT NOTES
# -anmation player connects to states -> ON ANIMATION CHANGED

const GRAVITY = 2400
const AIR_ACCEL = 32.5  # increase in this >> increase in stearing power in air old 34
const MAX_WIRE_LENGTH_GROUND = 1000
const INPUT_AGAIN_MARGIN = 0.12
const TIME_PER_ATTACK = 1.1

onready var animation_player = $AnimationPlayer
onready var animation_player_fx = $AnimationPlayerFx
onready var animation_player_fx_color = $AnimationPlayerFxColor
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
onready var circle_scan_small = $circleScanSmall
onready var shoulder_position = $bodyPivot/bodyRotate/shoulderPosition
onready var run_dust = preload("res://Effects/Dust/RunDust/runDust.tscn")
onready var land_dust = preload("res://Effects/Dust/JumpDust/jumpDust.tscn")

var level

var cur_state : Node
var prev_state : Node
var velocity = Vector2()
var actual_velocity = Vector2()
var look_direction = Vector2(1, 0) setget set_look_direction
var previous_anim : String
var is_invunerable = false
var prev_pos = Vector2()
var zone : Node # an area that the player is in

var has_jumped = false
var jump_again = false
var bounce_boost = false

var tip_pos : Vector2
var hook_dir : Vector2
var hooked : bool
var rope_length = 0.0
var nearest_hook_point

var exit_slide_blocked = false

var wall_direction = 0 # 0 or 1

enum SWORD_STATES {ON_HAND = 1, AIR = 2, STUCK = 3}
var sword_state = SWORD_STATES.ON_HAND

var throw_sword_dir = Vector2()
var sword_pos = Vector2()
var sword_col_normal = Vector2()

var can_hook = true

var attack_enabled = true # To enable/disable attacks completely
var can_attack = true # used to decide which state can attack
var attack_cooldown_finished = true
var attack_count = 0

var hit_dir : Vector2

var nearest_interactible : Node
var interaction_type : String

var can_talk = true

enum CAMERA_STATES {GROUND = 0, AIR = 1, HOOK = 2}
var camera_state = CAMERA_STATES.GROUND setget set_camera_mode_logic

signal hook_command
signal flying_sword_command
signal camera_command

func _ready():
	cur_state = states.current_state
	body_collision.disabled = false
	slide_collision.disabled = true
	$bodyPivot/bodyRotate/hurtBox/CollisionShape2D.disabled = true
	$bodyPivot/bodyRotate/hurtBox.obj = self
	add_to_group("needs_level_ref")

func _physics_process(delta):
	var old_nearest_hook_point = nearest_hook_point
	var old_nearest_interactible = nearest_interactible
	nearest_hook_point = get_nearest_object("hook_points")
	if nearest_hook_point != old_nearest_hook_point:
		if nearest_hook_point:
			nearest_hook_point.active = true # just a visual indicator
		if old_nearest_hook_point:
			old_nearest_hook_point.active = false

	nearest_interactible = get_nearest_object("interactibles")

	if nearest_interactible != old_nearest_interactible:
		if nearest_interactible:
			nearest_interactible.pend_interact()
		if is_instance_valid(old_nearest_interactible):
			old_nearest_interactible.unpend_interact()
	if nearest_interactible:
		interaction_type = nearest_interactible.interaction_type
	else:
		interaction_type = ""

# General Helper functions
func set_input_enabled(val : bool):
	states.input_enabled = val

func change_state(name : String):
	states._change_state(name)

func get_nearest_object(obj_type : String):
	var near_objects
	match obj_type:
		"hook_points":
			near_objects = circle_scan.get_overlapping_bodies()
		"interactibles":
			near_objects = circle_scan_small.get_overlapping_areas()
			near_objects += circle_scan_small.get_overlapping_bodies()
#
	var non_block_objects = []
	var space_state = get_world_2d().direct_space_state
	for object in near_objects:
		if not object.is_in_group(obj_type): continue
		var result = space_state.intersect_ray(global_position + Vector2(0,-50), object.global_position ,[self, object], 32)
		if result.empty(): non_block_objects.append( object)

	if non_block_objects.empty():
		return

	var min_dist_facing = INF
	var closest_object_facing_dir = null

	var facing_dir_x = sign(body_rotate.scale.x)

	for object in non_block_objects:
		var cur_dist = global_position.distance_to(object.global_position)
		# look for hooks in the direction character faces
		if facing_dir_x == sign(object.global_position.x - global_position.x) and min_dist_facing > cur_dist:
			min_dist_facing = cur_dist
			closest_object_facing_dir = object
	if closest_object_facing_dir:
		return closest_object_facing_dir

func interact_with_nearest_object():
	if nearest_interactible:
		nearest_interactible.interact(self)

# Makes character face right direction
func set_look_direction(direction : Vector2):
	if direction != Vector2() :look_direction = direction

	if direction.x in [-1, 1]:
		body_rotate.scale = Vector2(direction.x,1) # flips horizontally

func set_attack_enabled (val : bool):
	attack_enabled = val
func displace(vector : Vector2):
	global_position += vector

func _on_states_state_changed(states_stack):
	prev_state = cur_state
	cur_state = states_stack[0]

func set_fsm(val : bool):
	states._active = val

# Animation
func play_anim(string : String):
	if animation_player:
		animation_player.clear_queue()
		animation_player.play(string)
		previous_anim = string
		animation_player.advance(0) # play from the start of anim
func queue_anim(string : String):
	if animation_player:
			animation_player.queue(string)
			previous_anim = string
func play_and_return_anim(string : String):
	if animation_player:
		animation_player.play(string)
		animation_player.queue(previous_anim)
func stop_anim():
	if animation_player: animation_player.stop(false)
func set_anim_speed (val : float):
	if animation_player: animation_player.playback_speed = val
func play_anim_fx(string : String):
	if animation_player_fx: animation_player_fx.play(string)
func queue_anim_fx(string : String):
	if animation_player_fx: animation_player_fx.queue(string)

func play_anim_fx_color(string : String):
	if animation_player_fx_color: animation_player_fx_color.play(string)

# Grapple
func start_hook():
	emit_signal("hook_command",0, hook_dir,global_position)
	can_hook = false
	$timers/grappleCoolDown.start(.5)
func _on_grappleCoolDown_timeout():
	can_hook = true
func _on_Chain_hooked(command : int, tip_p : Vector2, node : Node):
	if command == 0: # good hook
		hooked = true
		tip_pos = tip_p
		rope_length = global_position.distance_to(tip_pos) # used to limit player distance from tip, she can't run from it
		change_state("hook")
	elif command == 1: # bad hook
		play_sound("hook_bad")
func get_close_to_floor_collider(): # used to repel player from floor
	return floor_raycast.get_collider()
func chain_release():
	hooked = false
	emit_signal("hook_command", 1,Vector2(),Vector2())
	can_hook = false
	$timers/grappleCoolDown.start(.05)

# Sword Throw
func start_sword_throw():
	sword_state = SWORD_STATES.AIR
	emit_signal("flying_sword_command", 0, throw_sword_dir)
func return_sword_throw():
	sword_state = SWORD_STATES.AIR
	emit_signal("flying_sword_command", 1, Vector2())
func on_sword_result(result : int, pos : Vector2, normal : Vector2):
	if result == 0: # hit
		sword_state = SWORD_STATES.STUCK
		sword_pos = pos
		sword_col_normal = normal
	elif result == 1: # returning
		sword_state = SWORD_STATES.AIR
	elif result == 2:
		sword_state = SWORD_STATES.ON_HAND # edge case when return during slide/wallslide

# Player damaged
func _on_hitBox_area_entered(area : Node):
	if is_invunerable: return
	is_invunerable = true

	if zone: global_position = zone.tele_pos

	var damage
	if damage in area: # write a better system
		damage = -area.damage
	else:
		damage = -10

	DataResource.change_health(damage)

	if DataResource.temp_dict_player.health_curr < 1: # change this to a better system to have less dependancies
		level.on_player_dead()

	if hooked: chain_release()

	hit_dir = global_position - area.global_position

	change_state("hit")

func set_player_invunerable(time : float):
	is_invunerable = true
	$timers/invunerableTimer.start(time)
func _on_invunerableTimer_timeout():
	is_invunerable = false

# Movement
func move():
	actual_velocity = (global_position - prev_pos) * 60
	prev_pos = global_position # used to calculate actual speed junmping of moving platform

	var reported_vel
	if hooked and not ["hook"].has(cur_state.name) and\
	(global_position + velocity).distance_to(tip_pos) > MAX_WIRE_LENGTH_GROUND: # when player is hooked but tried to move away from hook point
		reported_vel = move_and_slide(Vector2(), Vector2.UP)
	elif ["run", "slide", "idle", "wallSlide"].has(cur_state.name):
		reported_vel = move_and_slide_with_snap(velocity,Vector2.DOWN * 15, Vector2.UP)
	else:
		reported_vel = move_and_slide(velocity, Vector2.UP)

	handle_move_collisions()
	check_reset_attack()

	return reported_vel

# used to interact collision objects
func handle_move_collisions():
	for i in get_slide_count():
		var col = get_slide_collision(i)
#		if col:	print("COL", col.collider.name)
		if col.collider.has_method("handle_collision"):
			col.collider.handle_collision(col, self)

func check_reset_attack():
	if is_on_floor() and attack_cooldown_finished:
		can_attack = true
		attack_count = 0
		attack_cooldown_finished = false

func switch_col():
	call_deferred("_switch_col")
func _switch_col():
	slide_collision.disabled = not slide_collision.disabled
	body_collision.disabled = not body_collision.disabled

func _on_slideArea2D_body_exited(body : Node):
	if not body.is_in_group("one_way_platforms"):
		exit_slide_blocked = false
func _on_slideArea2D_body_entered(body : Node):
	if not body.is_in_group("one_way_platforms"):
		exit_slide_blocked = true

# Wall climb
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

# a position.y boost to the player incase barely missing the platform above
func is_almost_at_a_platform():
	return almost_reaching_platform_jump_boost.get_overlapping_bodies()
# returns 1 if corner on the right -1 if left, used to nudge player away from smashing corners
func is_there_corner_above():
	return int (corner_correction_raycast_right.is_colliding()) - int(corner_correction_raycast_left.is_colliding())

func emit_dust(type : String):
	var dust
	match type:
		"run" :
			dust = run_dust.instance()
		"land":
			dust = land_dust.instance()

	dust.scale.x = look_direction.x
	dust.global_position = global_position + Vector2(0, 68) - level.global_position
	dust.emitting = true

	level.add_child(dust)

# Jump input buffering
func jump_buffer_start():
	jump_again = true
	$timers/jumpInputBuffer.start(INPUT_AGAIN_MARGIN)
func _on_jumpInputBuffer_timeout():
	jump_again = false

# ATTACK
func start_attack_cool_down():
	attack_cooldown_finished = false
	$timers/attackCoolDown.start(TIME_PER_ATTACK)
func _on_attackCoolDown_timeout():
	attack_cooldown_finished = true

# Dialog
func talk_cooldown_start():
	can_talk = false
	$timers/talkCoolDown.start(.5)
func _on_Timer_timeout():
	can_talk = true

# Sound
func play_sound(string : String):
#	sound_parent.get_node(string).play()
	pass
func stop_sound(string : String):
	sound_parent.get_node(string).stop()
func volume(string, vol_db):
	sound_parent.get_node(string).volume_db = vol_db

# CAMERA  CONTROL PART
func set_camera_mode_logic(state : int):
	camera_state = state
	emit_signal("camera_command", camera_state, 0) # HOOK MODE
	match camera_state:
		CAMERA_STATES.AIR : emit_signal("camera_command", 0, 0)
		CAMERA_STATES.GROUND : emit_signal("camera_command", 0, 1)
		CAMERA_STATES.HOOK : emit_signal("camera_command", 1, 0)

func shake_camera(dur : float, freq : float, amp : float, dir : float):
	level.shake_camera(dur, freq, amp, dir)
