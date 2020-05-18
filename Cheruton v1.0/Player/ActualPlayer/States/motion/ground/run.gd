extends groundState

const MAX_RUN_SPEED = 500
const PLAYER_DIR_CONTROL = 13 # lower means mario
func enter():
	var input_direction = get_input_direction()
	update_look_direction(input_direction)
	owner.play_anim("run_continious")

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var input_direction = get_input_direction()
	update_look_direction(input_direction)

	owner.velocity.x = lerp(owner.velocity.x , MAX_RUN_SPEED * input_direction.x, delta*PLAYER_DIR_CONTROL)
	owner.velocity.y = 5
	owner.move_and_slide_with_snap(owner.velocity,Vector2.DOWN * 10, Vector2.UP) # look tiles down for a tile to snap to
	# note that the tilemap checks for collision with character, not the character itself checking the layer of the tile mask
	if not owner.is_on_floor():
		emit_signal("finished","fall")
	if not input_direction.x and abs(owner.velocity.x) < 50 :
		emit_signal("finished", "idle")
	.update(delta)
