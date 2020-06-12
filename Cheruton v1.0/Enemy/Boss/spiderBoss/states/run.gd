extends baseState


var goal_spider_pos

func enter():
	goal_spider_pos = owner.global_position

func update(delta):
	var out_of_pos_legs = owner.get_out_of_pos_legs()
	if out_of_pos_legs:
		for out_of_pos_leg in out_of_pos_legs:
			owner.step_leg(out_of_pos_leg)

	goal_spider_pos = owner.get_global_mouse_position()
	var dir_vec = goal_spider_pos - owner.global_position

	if dir_vec.length() < 10:
		owner.velocity = Vector2()
	else:
		owner.velocity = dir_vec.normalized() * 10

	owner.move()

