extends airState

const SPEED_BOOST = 1000

var dir
var save_col_layer
var save_col_mask

func handle_input(event): # disables all inputs
	pass

func enter():
	owner.can_dash = false
	save_col_layer = owner.collision_layer
	save_col_mask = owner.collision_mask
	owner.collision_layer = 0
	owner.collision_mask = 0
	owner.set_collision_layer_bit(2,1)
func update(delta):
	dir = (owner.sword_pos - owner.global_position).normalized()
	owner.velocity = dir*SPEED_BOOST
	owner.move()

	if owner.can_throw_sword:
		emit_signal("finished", "fall")

func exit():
	owner.collision_layer = save_col_layer
	owner.collision_mask = save_col_mask
