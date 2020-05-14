extends motionState

const PLAYER_ENTER_SLOWDOWN  = 1 # delete if don't need to slow player when entering hook state
const PULL_DOWN_STRENGTH = 0.55
const PULL_UP_STRENGTH = 1.65
const CHAIN_STRENGTH_FAST = 1000
const CHAIN_STRENGTH_SLOW = 0
const MAX_SPEED = 800
const ZIP_TIMER = .200 # time give to player to zip up before falling again
var zip_timer
var chain_pull
var chain_velocity = Vector2(0,0)
var zip_state


func enter():
	zip_state = false
	zip_timer = ZIP_TIMER
	chain_pull = CHAIN_STRENGTH_SLOW
	if owner.hook_dir == Vector2(): # if no input on enter
		owner.hook_dir = owner.look_direction
	owner.get_node("chain").shoot(owner.hook_dir)
	owner.velocity *= PLAYER_ENTER_SLOWDOWN

func update(delta):
	if Input.is_action_pressed("jump"):
		emit_signal("finished", "previous")
	elif not Input.is_action_pressed("hook"):
		zip_timer -= delta
		if zip_timer < 0:
			emit_signal("finished", "previous")
		return

	if owner.get_node("chain").hooked:
		if Input.is_action_just_pressed("hook"):
			chain_pull = CHAIN_STRENGTH_FAST
			zip_state = true
		else:
			chain_velocity = (owner.get_node("chain").get_node("tip").position).normalized() * chain_pull
			if chain_velocity.y > 0:
				chain_velocity.y *= PULL_DOWN_STRENGTH
			else:
				chain_velocity.y *= PULL_UP_STRENGTH
	else:
		chain_velocity = Vector2(0,0)

	owner.velocity = chain_velocity
	owner.velocity.y += owner.GRAVITY*.2

	owner.move_and_slide(owner.velocity, Vector2.UP)

	owner.velocity.y = clamp(owner.velocity.y, -MAX_SPEED, MAX_SPEED)
	owner.velocity.x = clamp(owner.velocity.x, -MAX_SPEED, MAX_SPEED)

func exit():
	owner.get_node("chain").release()
