extends groundState

const MAX_RUN_SPEED = 250
const PLAYER_DIR_CONTROL = 9.25 # lower means mario
const MIN_RUN_SPEED = 25

var previous_dir
func enter():
	var input_direction = get_input_direction()
	previous_dir = input_direction
	update_look_direction(input_direction)
	if get_parent().previous_state.name == "slide":
		owner.queue_anim("run_continious")
	else:
		owner.play_anim("run_continious")

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var input_direction = get_input_direction()
	update_look_direction(input_direction)
	if input_direction.x and input_direction != previous_dir:
		owner.play_anim("run_change_dir")
		owner.queue_anim("run_continious")
		previous_dir = input_direction
	owner.velocity.x = lerp(owner.velocity.x , MAX_RUN_SPEED * input_direction.x, delta*PLAYER_DIR_CONTROL)
	owner.velocity.y = 5
	owner.move() # look tiles down for a tile to snap to
	# note that the tilemap checks for collision with character, not the character itself checking the layer of the tile mask
	if not input_direction.x and abs(owner.velocity.x) < MIN_RUN_SPEED :
		emit_signal("finished", "idle")
	if Input.is_action_just_pressed("slide"):
		emit_signal("finished", "slide")
	.update(delta)

func exit():
	pass
