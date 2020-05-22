extends KinematicBody2D

# only put consts used by multiple states, no need to get owner each time
const GRAVITY = 2400
const TERM_VEL = 2400 # Terminal velocity when falling/ jumping straight up
const AIR_ACCEL = 28.5  # increase in this >> increase in stearing power in air

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
var prev_camera_logic = 0

onready var animation_player = $AnimationPlayer
onready var animation_player_fx = $AnimationPlayerFx
onready var left_wall_raycasts = $wallRaycasts/leftSide
onready var right_wall_raycasts = $wallRaycasts/rightSide
onready var sound_parent = $sounds
onready var body_rotate = $bodyPivot/bodyRotate/
onready var body_collision = $bodyCollision
onready var slide_collision = $slideCollision

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

# General Helper functions
func set_look_direction(value): # vector
	look_direction = value
func _on_states_state_changed(states_stack):
	emit_signal("state_changed", states_stack)
func signal_on_floor(grounded):
	on_floor = grounded
	set_camera_mode_logic()

# Animation
func play_anim(string):
	if animation_player:
		animation_player.play(string)
func queue_anim(string):
	if animation_player:
		animation_player.queue(string)
func play_anim_fx(string):
	if animation_player_fx:
		animation_player_fx.play(string)
func queue_anim_fx(string):
	if animation_player_fx:
		animation_player_fx.queue(string)


# Hook mechanics
func start_hook():
	emit_signal("hook_command",0, hook_dir,global_position)
func _on_Chain_hooked(command, tip_p):
	if command == 0:
		hooked = 1
		tip_pos = tip_p
		$states._change_state("hook")
		set_camera_mode_logic()
	elif command == 1: # bad hook
		play_sound("hook_bad")

func chain_release():
	hooked = false
	emit_signal("hook_command", 1,Vector2(),Vector2())

# Movement
func move():
	move_and_slide(velocity, Vector2.UP)
func move_with_snap():
	move_and_slide_with_snap(velocity,Vector2.DOWN * 10, Vector2.UP)
func switch_col():
		body_collision.disabled = not body_collision.disabled
		slide_collision.disabled = not slide_collision.disabled
func _on_slideArea2D_body_exited(body):
	exit_slide_blocked = false
func _on_slideArea2D_body_entered(body):
	exit_slide_blocked = true

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
func _process(delta):
	DataResource.dict_player.player_pos = global_position # this is previous, need to goto actual state physics to get current
	if hooked or not DataResource.dict_player.chain_in_air:
		stop_sound("hook_start")

# CAMERA  CONTROL PART
func set_camera_mode_logic():
	if hooked and prev_camera_logic != 0: # don't repeat unneccesary signals
		emit_signal("camera_command", 1, 0)
		prev_camera_logic = 0
	elif prev_camera_logic != 1:
		prev_camera_logic = 1
		if not ($states.previous_state.name == "hook" and $states.current_state is airState):
			emit_signal("camera_command", 0, on_floor)


func shake_camera(dur, freq, amp, dir):
	emit_signal("shake", dur, freq, amp, dir)


func _on_Area2D_body_entered(body):
	pass # Replace with function body.

