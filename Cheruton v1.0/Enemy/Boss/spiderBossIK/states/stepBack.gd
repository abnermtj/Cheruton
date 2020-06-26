extends baseState

const GRAVITY = 2900
enum stages{ANTICIPATION = 0, JUMP = 1, LAND = 2, RECOVER = 3}

var stage_switch_timer
var timers_dict = {"ANTICIPATION" : 1}
var stage
var step_back_dir
var goal_pos
var anticipation_vec = Vector2( 100, 200)
var jump_vec = Vector2(1400, -1200)
var save_cast_to : Vector2

func enter():
	step_back_dir = sign (owner.global_position.x - (owner.get_parent().get_node("player")).global_position.x)
	if not step_back_dir: step_back_dir = 1

	owner.diag_ray_cast_enable = false
	owner.floor_ray_cast_enable = false

	goal_pos = owner.global_position + Vector2(anticipation_vec.x * step_back_dir, anticipation_vec.y)
	stage = stages.ANTICIPATION
	stage_switch_timer = timers_dict.ANTICIPATION

func update(delta):
	stage_switch_timer -= delta
	match stage:
		stages.ANTICIPATION:
			owner.velocity = (goal_pos - owner.global_position) * 2
			owner.move()
			owner.move_body_sprites()
			if owner.is_on_floor():
				stage = stages.JUMP
				owner.velocity = Vector2(step_back_dir* jump_vec.x , jump_vec.y)
				for leg in owner.legs:
					leg.step_and_hold(leg.global_position + Vector2(0,250) , 0.2)
				save_cast_to = owner.ground_check.cast_to
				owner.ground_check.cast_to = Vector2(0 ,600) # so spider plants legs earlier
				owner.set_body_collision(1)
		stages.JUMP:
			owner.velocity.y +=  GRAVITY * delta
			owner.velocity.x = lerp(owner.velocity.x, 0, delta * 1.5)
			owner.move()
			owner.move_body_sprites()
			if owner.velocity.y > -400 and owner.ground_check.is_colliding():
				for leg in owner.legs:
					leg.set_offset(owner.velocity/2)
					var col_point = leg.get_collision_point()
					if col_point: leg.timed_step(col_point, 0.3)
			if owner.is_on_floor():
				stage = stages.LAND
				owner.velocity.y = 0
				owner.ground_check.cast_to = save_cast_to
		stages.LAND:
			owner.jump_hurt_box_col_shape.disabled = true
			owner.head_sprite.position.y = lerp(owner.head_sprite.position.y,  owner.default_sprite_pos[0].y ,delta)
			owner.butt_sprite.position.y = lerp(owner.butt_sprite.position.y,  owner.default_sprite_pos[3].y, delta)

			owner.velocity.x = lerp(owner.velocity.x,0 ,delta * 2)
			owner.velocity.y = lerp(owner.velocity.y, -400, delta)
			owner.move()
			if not owner.ground_check.is_colliding():
				stage = stages.RECOVER
		stages.RECOVER:

			emit_signal("finished", "run")
func exit():
	owner.set_body_collision(0)
	owner.diag_ray_cast_enable = true
	owner.floor_ray_cast_enable = true
