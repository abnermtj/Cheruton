extends groundState

export(float) var MAX_WALK_SPEED = 330
export(float) var MAX_RUN_SPEED = 360

func enter():
	speed = 0.0

	var input_direction = get_input_direction()
	update_look_direction(input_direction)
	owner.get_node("AnimationPlayer").play("run_continious")

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var input_direction = get_input_direction()


	speed = MAX_RUN_SPEED if Input.is_action_pressed("run") else MAX_WALK_SPEED
	var collision_info = move(speed, input_direction)
	if not input_direction.x and not owner.is_on_wall():
		emit_signal("finished", "idle")
	update_look_direction(input_direction)
	if not collision_info:
		return
	if speed == MAX_RUN_SPEED and collision_info.collider.is_in_group("environment"):
		return null

func move(speed, direction):
	owner.velocity = direction.normalized() * speed
	owner.velocity.y = 1 # to collide
	owner.move_and_slide_with_snap(owner.velocity,Vector2.DOWN * 8, Vector2.UP) #look 8 down for a vector to snap to
	if not owner.is_on_floor():
		emit_signal("finished","fall")
	if owner.get_slide_count() == 0:
		return
	return owner.get_slide_collision(0)
