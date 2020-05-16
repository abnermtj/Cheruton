extends groundState

const MAX_WALK_SPEED = 360
const MAX_RUN_SPEED = 360

func enter():
	var input_direction = get_input_direction()
	update_look_direction(input_direction)
	owner.play_anim("run_continious")

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var input_direction = get_input_direction()
	update_look_direction(input_direction)

	# sprint
	owner.velocity.x = MAX_RUN_SPEED if Input.is_action_pressed("run") else MAX_WALK_SPEED
	owner.velocity.x *= input_direction.x
	owner.velocity.y = 5
	owner.move_and_slide_with_snap(owner.velocity,Vector2.DOWN * 8, Vector2.UP) # look 8  tiles down for a tile to snap to

	if not owner.is_on_floor():
		emit_signal("finished","fall")
	if not input_direction.x :
		emit_signal("finished", "idle")
