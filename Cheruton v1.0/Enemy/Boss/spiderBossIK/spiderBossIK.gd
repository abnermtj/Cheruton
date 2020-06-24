extends KinematicBody2D

const SPEED = 465  # faster than player
const LEG_DIST_MARGIN = 700
const LEG_MOVE_COOLDOWN = .4 # default is
const LEG_RAY_OFFSET_ADJUSTER = .5

onready var a_legs = $ALegs.get_children()
onready var b_legs = $BLegs.get_children()
onready var legs = a_legs + b_legs
onready var head_sprite = $head
onready var feelers_sprite = $head/feelers
onready var mid_body_sprite = $midBody
onready var butt_sprite = $butt
onready var ground_check = $groundCheck

onready var default_sprite_pos = []

var flip_legs = false
var is_scaling_walls = false
var leg_move_timer
var velocity = Vector2()
var desired_velocity = Vector2()
# PROBLEMS TO FIX
# ONLY ONE LEG AT A TIME, leg is always moving regardless of dist
# need to alternate legs and move only when dist past  a threshhold


# logical problems to solve
# WHEN MOVING  the body is lifter up to make su body don't crash into things
# SIde check so when crawling wall

# FOR EACH LEG. MOVE EACH LEG INDIVIDUALLY, cannot move legs until timer runs out .1s
# this way you can only send out the next leg once the current leg is .1 s lifter off already
# each time you move a leg only move the one currently farthest from the goal
func _ready():
	leg_move_timer = LEG_MOVE_COOLDOWN
	for leg in legs:
		init_leg(leg)
	default_sprite_pos = [head_sprite.position, feelers_sprite.position, mid_body_sprite.position, butt_sprite.position]

func init_leg(leg):
	leg.force_raycast_update()
	var col_point = leg.get_collision_point()
	if col_point: leg.step(col_point)

func _physics_process(delta):
	var next_position =  0.9*((get_parent().get_node("player")).global_position ) + Vector2(0, -200) # the offset account for the spider never touching the player due to hitbox

	next_position = get_global_mouse_position()

	if ground_check.is_colliding() and velocity.length() > SPEED/3:
		next_position.y -= ground_check.get_collision_point().y - global_position.y + 10 # const makes it bob less jittery

	desired_velocity =  next_position - global_position

	if desired_velocity.length() > SPEED:
		desired_velocity = desired_velocity.normalized() * SPEED

	velocity = lerp(velocity, desired_velocity, 2 * delta)

	velocity = move_and_slide(velocity)
	move_body_sprites()

# moves the parts of the body according to the velocity
func move_body_sprites():
	head_sprite.position = default_sprite_pos[0] + (velocity * 0.02).clamped(15)
	feelers_sprite.position = default_sprite_pos[1] + (velocity * 0.01).clamped(0)
	mid_body_sprite.position = default_sprite_pos[2] + velocity.clamped(0)
	butt_sprite.position = default_sprite_pos[3] - (velocity * 0.032).clamped(48)

func get_highest_tip_y():
	var highest_tip_y = INF
	for leg in legs:
		var cur_tip_pos_y = leg.get_tip_pos().y
		if cur_tip_pos_y < highest_tip_y: highest_tip_y = cur_tip_pos_y

	if highest_tip_y != INF : return highest_tip_y

func _process(delta):
	leg_move_timer -= delta
	if leg_move_timer > 0 : return

	var max_leg_dist_from_desired = 0
	is_scaling_walls = false

	for leg in a_legs:
		max_leg_dist_from_desired = check_most_displaced_leg(leg, true, max_leg_dist_from_desired)
	for leg in b_legs:
		max_leg_dist_from_desired = check_most_displaced_leg(leg, false, max_leg_dist_from_desired)

	if flip_legs:
		for leg in a_legs:
			if leg.is_step_over(): move_leg(leg)
		leg_move_timer = LEG_MOVE_COOLDOWN
	else:
		for leg in b_legs:
			if leg.is_step_over(): move_leg(leg)
		leg_move_timer = LEG_MOVE_COOLDOWN

# returns true if moving A legs, B is moving B legs
func check_most_displaced_leg(leg, desired_flip, cur_max):
	if not leg.is_colliding_ground(): is_scaling_walls = true
	leg.set_offset(velocity * LEG_RAY_OFFSET_ADJUSTER)

	var dist = leg.get_dist_from_desired()
	if dist and dist  > cur_max:
		cur_max = dist
		flip_legs = desired_flip
	return cur_max

func move_leg(leg):
	# moves ray to adjust for different velocities
	var desired_pos = leg.get_collision_point()
	if not desired_pos: return
	$Sprite2.global_position = desired_pos # debug

	var adjusted_leg_dist_margin = LEG_DIST_MARGIN * clamp (abs(velocity.x) /SPEED, .66, 2)
	if leg.get_tip_dist_to_point(desired_pos) > adjusted_leg_dist_margin:
		leg.step(desired_pos)
