extends baseState

enum stages {ANTICIPATION  = 0, STAB = 1, RECOVER = 2}

var timers_dict = {"ANTICIPATION" : 1.5, "STAB" : 0.5}
var stage
var stage_switch_timer
var leg_move_timer
var desired_pos_body
var desired_pos_arms_anticipation = Vector2(-10, 130) # relative to the parent
var desired_pos_arms_stab = Vector2(-800, 700) # relative to the parent

func enter():
	stage = stages.ANTICIPATION

	leg_move_timer = owner.LEG_MOVE_COOLDOWN
	stage_switch_timer = timers_dict.ANTICIPATION

	owner.front_left_leg.step_and_hold(owner.front_left_leg.global_position + Vector2(-desired_pos_arms_anticipation.x ,desired_pos_arms_anticipation.y), 0.4)
	owner.front_right_leg.step_and_hold(owner.front_right_leg.global_position + desired_pos_arms_anticipation, 0.4)

func update(delta):
	stage_switch_timer -= delta
	match stage:
		stages.ANTICIPATION:
			var next_position =  0.9*((owner.get_parent().get_node("player")).global_position ) + Vector2(0, -325)
			owner.velocity = next_position - owner.global_position
			owner.move()
			owner.move_body_sprites()

			if stage_switch_timer < 0:
				owner.front_left_leg.set_tip_hurt_box_disabled(false)
				owner.front_left_leg.step_and_hold(owner.front_left_leg.global_position + Vector2(-desired_pos_arms_stab.x ,desired_pos_arms_stab.y), 0.2)
				owner.front_right_leg.set_tip_hurt_box_disabled(false)
				owner.front_right_leg.step_and_hold(owner.front_right_leg.global_position + desired_pos_arms_stab, 0.2)

				stage_switch_timer = timers_dict.STAB
				stage = stages.STAB
		stages.STAB:
			var next_position =  0.9*((owner.get_parent().get_node("player")).global_position ) + Vector2(0, -150)
			owner.velocity = next_position - owner.global_position
			owner.move()
			stab_move_body_sprites()

			if stage_switch_timer < 0:
				stage = stages.RECOVER
		stages.RECOVER:
			emit_signal("finished", "run")

	owner.move()

func stab_move_body_sprites():
	owner.desired_head_pos = owner.default_sprite_pos[0] + (owner.velocity * 0.2).clamped(300)
	owner.desired_feeler_pos = owner.default_sprite_pos[1] + (owner.velocity * 0.01).clamped(0)
	owner.desired_mid_body_pos = owner.default_sprite_pos[2] + owner.velocity.clamped(0)
	owner.desired_butt_pos =owner. default_sprite_pos[3] - (owner.velocity * 0.1).clamped(48)

func update_idle(delta):
	match stage:
		stages.ANTICIPATION, stages.STAB:
			leg_move_timer -= delta
			if leg_move_timer > 0 : return

			var max_leg_dist_from_desired = 0

			for leg in owner.a_legs:
				if leg != owner.front_right_leg: max_leg_dist_from_desired = owner.check_most_displaced_leg(leg, true, max_leg_dist_from_desired)
			for leg in owner.b_legs:
				if leg != owner.front_left_leg: max_leg_dist_from_desired = owner.check_most_displaced_leg(leg, false, max_leg_dist_from_desired)

			if owner.flip_legs:
				for leg in owner.a_legs:
					if leg != owner.front_right_leg and leg.is_step_over(): get_parent().get_node("run").move_leg(leg)
				leg_move_timer = owner.LEG_MOVE_COOLDOWN
			else:
				for leg in owner.b_legs:
					if leg != owner.front_left_leg and leg.is_step_over(): get_parent().get_node("run").move_leg(leg)
				leg_move_timer = owner.LEG_MOVE_COOLDOWN

func exit():
	var col_point = owner.front_left_leg.get_collision_point() # Resets the legs
	var col_point2 = owner.front_right_leg.get_collision_point()
	if col_point:  owner.front_left_leg.step(col_point)
	if col_point2:  owner.front_right_leg.step(col_point2)

	owner.front_left_leg.set_tip_hurt_box_disabled(true)
	owner.front_right_leg.set_tip_hurt_box_disabled(true)
