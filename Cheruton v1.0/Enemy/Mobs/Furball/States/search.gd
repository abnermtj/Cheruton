extends baseState

const JUMP_VEL = -750

var goal_pos
var jump_started : bool

func enter():
	owner.play_anim("jump")
	jump_started = false

func jump(): #called by animation player
	owner.velocity.y =  JUMP_VEL
	jump_started = true

func update( delta ):
	if jump_started:
		if owner.return_to_sleep:
			goal_pos = owner.initial_pos
		else:
			goal_pos = owner.player.global_position

		owner.velocity.x = clamp(goal_pos.x - owner.global_position.x, -owner.MAX_X_VEL, owner.MAX_X_VEL)
		owner.velocity.y = min( owner.TERMINAL_VELOCITY, owner.velocity.y + owner.GRAVITY * delta)
		owner.look_dir = Vector2(sign(owner.velocity.x),0)

	if owner.velocity.y > 0:
		emit_signal("finished","fall")
	owner.move()
