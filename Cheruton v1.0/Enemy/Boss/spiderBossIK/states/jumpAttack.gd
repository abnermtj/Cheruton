extends baseState

const JUMP_VEL = -4000
const GRAVITY = 2500
enum stages {ANTICIPATION  = 0, JUMP = 1, LAND = 2, RECOVER = 3}

var timers_dict = {"ANTICIPATION" : 1.5}
var stage
var timer

func enter():
	stage = stages.ANTICIPATION

	for leg in owner.legs: # setup rihght before jump attack
		var desired_pos = leg.get_collision_point()
		if  desired_pos: leg.step(desired_pos)
	timer = timers_dict["ANTICIPATION"]
	owner.set_body_collision(1)
	owner.diag_ray_cast_enable = false
	owner.floor_ray_cast_enable = false


func update(delta):
	match stage:
		stages.ANTICIPATION:
			timer -= delta
			if timer < 0:
				stage = stages.JUMP
				owner.velocity = Vector2(0, JUMP_VEL)
				owner.move()
				return
			owner.head_sprite.position.y = lerp(owner.head_sprite.position.y,  owner.default_sprite_pos[0].y + 40,delta)
			owner.butt_sprite.position.y = lerp(owner.butt_sprite.position.y,  owner.default_sprite_pos[3].y -40,delta)

			owner.velocity.x = lerp(owner.velocity.x , 0 , delta)
			owner.velocity.y = lerp(owner.velocity.y , 400 , delta)
			owner.move()
		stages.JUMP:
			owner.velocity.y += GRAVITY * delta
			owner.move()
			if owner.is_on_floor():
				stage = stages.LAND
				owner.jump_hurt_box_col_shape.disabled = false
				owner.velocity = Vector2()
		stages.LAND:
			owner.jump_hurt_box_col_shape.disabled = true
			owner.head_sprite.position.y = lerp(owner.head_sprite.position.y,  owner.default_sprite_pos[0].y ,delta)
			owner.butt_sprite.position.y = lerp(owner.butt_sprite.position.y,  owner.default_sprite_pos[3].y, delta)

			owner.velocity.y = lerp(owner.velocity.y, -200, delta)
			owner.move()
			if not owner.ground_check.is_colliding():
				stage = stages.RECOVER
		stages.RECOVER:
			emit_signal("finished", "run")

func exit():
	owner.set_body_collision(0)
	owner.diag_ray_cast_enable = true
	owner.floor_ray_cast_enable = true
