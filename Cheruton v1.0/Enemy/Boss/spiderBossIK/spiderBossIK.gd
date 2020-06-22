extends KinematicBody2D

const SPEED = 100
const LEG_DIST_MARGIN = 90
const LEG_MOVE_COOLDOWN = .4
#const LEG_EXTENSION_MARGIN_MIN = 20
#const LEG_EXTENSION_MARGIN_MAX = 300


onready var a_legs = $ALegs.get_children()
onready var b_legs = $BLegs.get_children()
onready var legs = a_legs + b_legs

var flip_legs = false
var leg_move_timer
var velocity = Vector2()
# PROBLEMS TO FIX
# ONLY ONE LEG AT A TIME, leg is always moving regardless of dist
# need to alternate legs and move only when dist past  a threshhold


# logical problems to solve
# move a single leg according to the is passess that dist
# multiple legs, multiple rays
# have legs alternate
# make leg hover when cannot dcide
# NO NEED body pos is the average of leg positions NO NEED I LOIKE FOLLOWING CURSOR
#making head move with velocity

# FOR EACH LEG. MOVE EACH LEG INDIVIDUALLY, cannot move legs until timer runs out .1s
# this way you can only send out the next leg once the current leg is .1 s lifter off already
# each time you move a leg only move the one currently farthest from the goal

func _ready():
	leg_move_timer = LEG_MOVE_COOLDOWN

	for leg in legs:
		init_leg(leg)

func init_leg(leg):
	leg.force_raycast_update()
	var col_point = leg.get_collision_point()
	if col_point: leg.step(col_point)

func _physics_process(delta):
	velocity = SPEED * (get_global_mouse_position() - global_position).normalized() # head follows mouse
	move_and_collide(velocity * delta)

func _process(delta):
	leg_move_timer -= delta
	if leg_move_timer > 0 : return

	var max_leg_dist_from_desired = 0


	for leg in a_legs:
		var dist = leg.get_dist_from_desired()
		if dist  > max_leg_dist_from_desired: max_leg_dist_from_desired = dist

	if flip_legs:
		for leg in a_legs:
			if leg.is_grounded(): move_leg(leg)

#			move_leg(leg)
		flip_legs = not flip_legs
		leg_move_timer = LEG_MOVE_COOLDOWN
	else:
		for leg in b_legs:
			if leg.is_grounded(): move_leg(leg)
		flip_legs = not flip_legs
		leg_move_timer = LEG_MOVE_COOLDOWN

func move_leg(leg):
	# moves ray to adjust for different velocities
	leg.set_offset(velocity.x)
	var desired_pos
	if leg.is_colliding():
		desired_pos = leg.get_collision_point()
	else:
		return

	if leg.get_tip_dist_to_point(desired_pos) > LEG_DIST_MARGIN:
		leg.step(desired_pos)
