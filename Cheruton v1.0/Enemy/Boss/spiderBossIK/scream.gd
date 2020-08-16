extends baseState

const JUMP_VEL = -4600
const GRAVITY = 4000
enum stages {ANTICIPATION  = 0, SCREAM = 1, RECOVER = 2}

var timers_dict = {"ANTICIPATION" : 1, "SCREAM" : 2}
var stage : int
var timer : float

func enter():
	stage = stages.ANTICIPATION

	for leg in owner.legs: #step every leg to ideal spot
		var desired_pos = leg.get_collision_point()
		if  desired_pos: leg.step(desired_pos)


	owner.desired_head_pos.y = owner.default_sprite_pos[0].y - 100
	owner.desired_butt_pos.y = owner.default_sprite_pos[3].y + 40
	timer = timers_dict["ANTICIPATION"]


func update(delta):
	timer -= delta
	match stage:
		stages.ANTICIPATION:
			if timer < 0 and not owner.ground_check.is_colliding():
				timer = timers_dict["SCREAM"]
				stage = stages.SCREAM
				owner.sprite_move_speed_modifier = 3.0
				owner.desired_head_pos.y = owner.default_sprite_pos[0].y + 60
				owner.desired_butt_pos.y = owner.default_sprite_pos[3].y - 20

				owner.velocity.y = 500
				return


			owner.velocity.x = lerp(owner.velocity.x , 0 , delta)
			owner.velocity.y = lerp(owner.velocity.y , -200 , delta)

		stages.SCREAM:
			if timer < 0:
				stage = stages.RECOVER
				return



			owner.velocity.x = lerp(owner.velocity.x , 0 , delta)
			owner.velocity.y = lerp(owner.velocity.y , 0 , delta * 2)

		stages.RECOVER:
			owner.velocity.x = lerp(owner.velocity.x , 0 , delta)
			owner.velocity.y = lerp(owner.velocity.y , 400 , delta)
			if owner.is_on_floor():
				emit_signal("finished", "run")

	owner.move()

func exit():
	owner.sprite_move_speed_modifier = 1.0
