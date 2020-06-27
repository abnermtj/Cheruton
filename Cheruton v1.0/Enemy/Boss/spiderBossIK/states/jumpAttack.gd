extends baseState

const JUMP_VEL = -4600
const GRAVITY = 4000
enum stages {ANTICIPATION  = 0, JUMP = 1, LAND = 2, RECOVER = 3}

var timers_dict = {"ANTICIPATION" : 1.5}
var stage : int
var timer : float
var legs_repositioned : bool

func enter():
	stage = stages.ANTICIPATION

	for leg in owner.legs: # setup rihght before jump attack
		var desired_pos = leg.get_collision_point()
		if  desired_pos: leg.step(desired_pos)
	timer = timers_dict["ANTICIPATION"]
	legs_repositioned = false
	owner.set_body_collision(2)
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
			var player_pos = owner.player.global_position
			owner.velocity.x = (player_pos.x - owner.global_position.x ) * .75
			if not legs_repositioned and owner.velocity.y > 0:
				legs_repositioned = true
				owner.hide()
				var save_pos = owner.global_position
				owner.global_position = player_pos + Vector2(0, -300)

				for leg in owner.legs:
					leg.force_raycast_update()
					var col_point = leg.get_collision_point()
					if col_point: leg.step(col_point)

				owner.global_position = save_pos
				owner.show()

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

			if not owner.ground_check.is_colliding(): # need more ray casts in the future if need to stand up at a corner, cuz the middle of body may not be on the floor side
				stage = stages.RECOVER

		stages.RECOVER:
			emit_signal("finished", "run")

func exit():
	owner.set_body_collision(0)
	owner.diag_ray_cast_enable = true
	owner.floor_ray_cast_enable = true
