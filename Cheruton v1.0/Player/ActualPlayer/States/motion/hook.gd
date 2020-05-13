extends motionState

# enter maybe slowdown the player velocity  to a halt no matter which state came from

const PLAYER_ENTER_SLOWDOWN  = 0.4
const CHAIN_PULL = 200

const PULL_DOWN_STRENGTH = 0.55
const PULL_UP_STRENGTH = 1.65

const MAX_SPEED = 800

var chain_velocity = Vector2(0,0)

func enter():
	owner.get_node("chain").shoot(owner.hook_dir)
	owner.velocity *= PLAYER_ENTER_SLOWDOWN

func update(delta):
	if !Input.is_action_pressed("hook"):
		emit_signal("finished", "previous")

	owner.velocity.y += owner.GRAVITY

	if owner.get_node("chain").hooked:
		chain_velocity = (owner.get_node("chain").get_node("tip").position).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			chain_velocity.y *= PULL_DOWN_STRENGTH
		else:
			chain_velocity.y *= PULL_UP_STRENGTH
	else:
		chain_velocity = Vector2(0,0)

	owner.velocity = chain_velocity

	print(chain_velocity)
	owner.move_and_slide(owner.velocity, Vector2.UP)
	# after moving clamp velocity
	owner.velocity.y = clamp(owner.velocity.y, -MAX_SPEED, MAX_SPEED)	# Make sure we are in our limits
	owner.velocity.x = clamp(owner.velocity.x, -MAX_SPEED, MAX_SPEED)




func exit():
	owner.get_node("chain").release()
