extends baseState
const AIR_CONTROL = 100

var goal_pos

func enter():
	owner.queue_anim("fall")

func update(delta):
	if owner.return_to_sleep:
		goal_pos = owner.initial_pos
	else:
		goal_pos = owner.player.global_position

	var dir = goal_pos - owner.global_position

	owner.velocity.x = lerp(owner.velocity.x, sign(dir.x) * AIR_CONTROL, delta * .5)
	if abs(owner.velocity.x) < 5: # this prevents oscilations when close to player
		owner.velocity.x = 0

	owner.velocity.y = min( owner.TERMINAL_VELOCITY, owner.velocity.y + owner.GRAVITY * delta)
	owner.look_dir = Vector2(sign(owner.velocity.x),0)

	owner.move()

	if owner.is_on_floor():
		emit_signal("finished", "idle")
