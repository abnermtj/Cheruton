extends Enemy

const MIN_MOVE_THRESHOLD_DIST = 150

onready var front_legs = $frontLegs.get_children()
onready var back_legs = $backLegs.get_children()

var leg_to_ray_dict = {}
var velocity

func _ready():
	leg_to_ray_dict = {
	$frontLegs/leg1 : $frontLegRays/leg1ray,
	$frontLegs/leg2 : $frontLegRays/leg2ray,
	$frontLegs/leg3 : $frontLegRays/leg3ray,
	$frontLegs/leg4 : $frontLegRays/leg4ray,
	$backLegs/leg1 : $backLegRays/leg1ray,
	$backLegs/leg2 : $backLegRays/leg2ray,
	$backLegs/leg3 : $backLegRays/leg3ray,
	$backLegs/leg4 : $backLegRays/leg4ray
	}

func move():
	move_and_collide(velocity)

func get_out_of_pos_legs():
	var out_of_pos_legs = []
	for leg in front_legs:
		if leg.is_grounded: continue
		if leg.cur_goal_pos.distance_to(leg_to_ray_dict[leg].get_collision_point()) > MIN_MOVE_THRESHOLD_DIST:
			out_of_pos_legs.append(leg)
	for leg in back_legs:
		if leg.is_grounded: continue
		if leg.cur_goal_pos.distance_to(leg_to_ray_dict[leg].get_collision_point()) > MIN_MOVE_THRESHOLD_DIST:
			out_of_pos_legs.append(leg)
	return out_of_pos_legs

func step_leg(leg):
	leg.step(leg_to_ray_dict[leg].get_collision_point())
