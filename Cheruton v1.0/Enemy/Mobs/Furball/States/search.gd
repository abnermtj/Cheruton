extends baseState

const JUMP_VEL = -750

var goal_pos
var jump_started : bool

func enter():
	owner.play_anim("jump")
	jump_started = false

func jump(): #called by animation player
	owner.velocity.y =  JUMP_VEL + rand_range(-100, 100) # this helps to remove syncing of multiple mob animations
	jump_started = true

func update( delta ):
	if not jump_started:
		owner.velocity.x = lerp(owner.velocity.x, 0, delta * 2.5)
	else:
		if owner.return_to_default:
			if owner.patrolling:
				goal_pos = owner.initial_pos + Vector2(owner.patrol_range_x * owner.flip_patrol_end, 0)
			else:
				goal_pos = owner.initial_pos
		else:
			goal_pos = owner.player.global_position

		owner.velocity.x = lerp(owner.velocity.x, goal_pos.x - owner.global_position.x, delta * 12)
		owner.velocity.x = clamp(owner.velocity.x, -owner.MAX_X_VEL, owner.MAX_X_VEL)
		owner.velocity.y = min( owner.TERMINAL_VELOCITY, owner.velocity.y + owner.GRAVITY * delta)
		owner.look_dir = Vector2(sign(owner.velocity.x),0)

	if owner.velocity.y > 0:
		emit_signal("finished","fall")
	owner.move()
