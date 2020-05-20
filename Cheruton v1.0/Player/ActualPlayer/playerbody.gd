extends KinematicBody2D

# only put consts used by multiple states, no need to get owner each time
const GRAVITY = 2400
const TERM_VEL = 1000 # Terminal velocity when falling/ jumping straight up
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

onready var animation_player = $AnimationPlayer

signal state_changed
signal hook_command
signal camera_command
signal shake



func take_damage(attacker, amount, effect=null):
	if self.is_a_parent_of(attacker):
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

# Hook mechanics
func start_hook():
	emit_signal("hook_command",0, hook_dir,global_position)
func _on_Chain_hooked(tip_p):
	hooked = 1
	tip_pos = tip_p
	$states._change_state("hook")
	set_camera_mode_logic()
func chain_release():
	hooked = false
	emit_signal("hook_command", 1,Vector2(),Vector2())

# Movement
func move():
	move_and_slide(velocity, Vector2.UP)
func move_with_snap():
	move_and_slide_with_snap(velocity,Vector2.DOWN * 10, Vector2.UP)
func switch_col():
		$bodyCollision.disabled = not $bodyCollision.disabled
		$slideCollision.disabled = not $slideCollision.disabled
func _on_slideArea2D_body_exited(body):
	exit_slide_blocked = false
func _on_slideArea2D_body_entered(body):
	exit_slide_blocked = true


func _process(delta):
	DataResource.dict_player.player_pos = global_position # this is previous, need to goto actual state physics to get current

# CAMERA  CONTROL PART
func set_camera_mode_logic():
	if hooked:
		emit_signal("camera_command", 1, 0)
	else:
		if not ($states.previous_state_name == "hook" and $states.current_state is airState):
			emit_signal("camera_command", 0, on_floor)
func shake_camera(dur, freq, amp, dir):
	emit_signal("shake", dur, freq, amp, dir)



func _on_Area2D_body_entered(body):
	pass # Replace with function body.

