extends groundState

const MAX_RUN_SPEED = 700 # 420 is normal 500
const PLAYER_DIR_CONTROL = 9.25 # lower means mario
const MIN_RUN_SPEED = 50

var previous_dir : Vector2
var input_direction : Vector2

func handle_input(event):
	input_direction = get_input_direction()
	owner.look_direction = input_direction

	if Input.is_action_just_pressed("slide"):
		emit_signal("finished", "slide")
	return .handle_input(event)

func enter():
	input_direction = get_input_direction()
	previous_dir = input_direction
	owner.look_direction = input_direction
	if owner.prev_state.name == "slide":
		owner.queue_anim("run_continious")
	else:
		owner.play_anim("run_continious")

func update(delta):
	if input_direction.x and input_direction.x != previous_dir.x:
		owner.play_anim("run_change_dir")

		var dir_name = "left" if input_direction.x == -1 else "right"
		owner.play_anim_fx("run_change_dir_"+ dir_name)

		owner.queue_anim("run_continious")

		previous_dir = input_direction
		if abs(owner.velocity.x) > 200:
			owner.emit_dust("run")

	owner.velocity.x = lerp(owner.velocity.x , MAX_RUN_SPEED * input_direction.x, delta*PLAYER_DIR_CONTROL)
	owner.velocity.y = 5
	owner.move()

	if not input_direction.x and abs(owner.velocity.x) < MIN_RUN_SPEED :
		emit_signal("finished", "idle")
	.update(delta)
