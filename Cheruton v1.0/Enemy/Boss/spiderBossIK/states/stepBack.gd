extends baseState

const GRAVITY = 4000
enum stages{ANTICIPATION = 0, JUMP = 1, LAND = 2, RECOVER = 3}

var stage : int
var stage_switch_timer : float
var timers_dict = {"ANTICIPATION" : 1}
var step_back_dir : int
var goal_pos : Vector2
var anticipation_vec = Vector2(100, 225)
var jump_vec = Vector2(1250, -600)
var save_cast_to : Vector2

func enter():
	step_back_dir = sign(owner.global_position.x - owner.player.global_position.x)
	if not step_back_dir: step_back_dir = 1

	owner.diag_ray_cast_enable = false
	owner.floor_ray_cast_enable = false

	goal_pos = owner.global_position + Vector2(anticipation_vec.x * step_back_dir, anticipation_vec.y)
	stage = stages.ANTICIPATION
	stage_switch_timer = timers_dict.ANTICIPATION

func update(delta):
	stage_switch_timer -= delta
	var close_to_ground = owner.ground_check.is_colliding()

	match stage:
		stages.ANTICIPATION:
			owner.velocity = (goal_pos - owner.global_position) * 1.5
			owner.move()
			move_body_sprites()

			if owner.is_on_floor() or (owner.global_position - goal_pos).length() < 10:
				stage = stages.JUMP
				owner.velocity = Vector2(step_back_dir* jump_vec.x , jump_vec.y)

				for leg in owner.legs:
					leg.step_and_hold(leg.global_position + Vector2(0,350) , 0.45)

				save_cast_to = owner.ground_check.cast_to
				owner.ground_check.cast_to = Vector2(0 ,700) # so spider plants legs earlier
				owner.set_body_collision(2)

		stages.JUMP:
			if close_to_ground and (owner.ground_check.get_collision_point().y - owner.global_position.y) < 500:
					owner.velocity.y = lerp(owner.velocity.y, 100, delta * 0.45) # gives the effect that legs are cushioning landing
			else:
				owner.velocity.y +=  GRAVITY * delta
			owner.velocity.x = lerp(owner.velocity.x, 0, delta * 2)
			owner.move()
			move_body_sprites()

			if owner.velocity.y > -300 and close_to_ground: # note close_to_ground affected by cast_to property of ray, which we modified above
				for leg in owner.legs:
					if leg.just_planted: continue

					leg.set_offset(owner.velocity)
					if leg.is_step_over(): move_leg(leg)

			if owner.is_on_floor():
				stage = stages.LAND
				owner.velocity.y = 0
				owner.ground_check.cast_to = save_cast_to

		stages.LAND:
			owner.jump_hurt_box_col_shape.disabled = true
			owner.desired_head_pos.y = owner.default_sprite_pos[0].y
			owner.desired_butt_pos.y = owner.default_sprite_pos[3].y

			owner.velocity.x = lerp(owner.velocity.x,0 ,delta * 2)
			owner.velocity.y = lerp(owner.velocity.y, -600, delta * 2)
			owner.move()

			if not close_to_ground:
				stage = stages.RECOVER

		stages.RECOVER:
			emit_signal("changeState", "webShoot")

func move_leg(leg):
	var desired_pos = leg.get_collision_point()
	if not desired_pos: return
	leg.timed_step(desired_pos, .35)
	leg.just_planted = true

func move_body_sprites():
	owner.desired_head_pos = owner.default_sprite_pos[0]  + Vector2(clamp(owner.velocity.x * 0.3, -20, 20), clamp(-owner.velocity.y, -150, 100))
	owner.desired_feeler_pos = owner.default_sprite_pos[1] + (owner.velocity * 0.01).clamped(0)
	owner.desired_mid_body_pos = owner.default_sprite_pos[2] + owner.velocity.clamped(0)
	owner.desired_butt_pos = owner.default_sprite_pos[3] +  Vector2(clamp(owner.velocity.x * 0.32, -20, 20), clamp(owner.velocity.y * .32, -100, 100))

func exit():
	owner.set_body_collision(0)
	owner.diag_ray_cast_enable = true
	owner.floor_ray_cast_enable = true

	for leg in owner.legs:
		leg.just_planted = false
