extends KinematicBody2D

const GRAVITY = 2400
const COYOTE_TIME = 0.12 # time after leaving edge before you are not allowed to jump
const JUMP_AGAIN_MARGIN = 0.2 # seconds need to press jump this amout of time for it to input buffer
const TERM_VEL = 640 # Terminal velocity when falling
const JUMP_RELEASE_SLOWDOWN = .5 #after releasing jump key how much to slow down by 0 to 1
#const SNAP_LEN = 8  # used to move and slide with snap when there are moving platforms

const JUMP_VEL = -700.0  # jump power
const MAX_VEL = 280 # when steering left and right during jump
const AIR_ACCEL = 40  # increase in this >> increase in stearing power in air

var velocity = Vector2()

var has_jumped = false
signal state_changed
signal direction_changed(new_direction)

var look_direction = Vector2(1, 0) setget set_look_direction

func take_damage(attacker, amount, effect=null):
	if self.is_a_parent_of(attacker):
		return
	$States/Stagger.knockback_direction = (attacker.global_position - global_position).normalized()
	$Health.take_damage(amount, effect)

func set_dead(value): # non zero means dead
	set_process_input(not value)
	set_physics_process(not value)
	$CollisionPolygon2D.disabled = value

func set_look_direction(value):
	look_direction = value
	emit_signal("direction_changed", value)


func _on_states_state_changed(states_stack):
	emit_signal("state_changed", states_stack)
