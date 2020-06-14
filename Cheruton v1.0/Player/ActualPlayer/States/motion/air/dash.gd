extends airState

const SPEED_BOOST = 1000

var dir : Vector2
var save_col_layer : int
var save_col_mask : int

func handle_input(event): # disables all inputs
	pass

func enter():
	owner.sword_stuck = false # so cannot repeatedly dash
	save_col_layer = owner.collision_layer
	save_col_mask = owner.collision_mask
	owner.collision_layer = 2 # pass through all physics bodies
	owner.collision_mask = 0

func update(delta):
	dir = (owner.sword_pos - owner.global_position).normalized()
	owner.velocity = dir*SPEED_BOOST
	owner.move()

	if owner.can_throw_sword: emit_signal("finished", "fall") # i e we picked up the sword

func exit():
	owner.collision_layer = save_col_layer
	owner.collision_mask = save_col_mask
