extends motionState

const PLAYER_ENTER_SLOWDOWN  = 1 # delete if don't need to slow player when entering hook state
const PULL_DOWN_STRENGTH = 0.55
const PULL_UP_STRENGTH = 1.65
const CHAIN_STRENGTH_FAST = 1000
const CHAIN_STRENGTH_SLOW = 0
const MAX_SPEED = 800
const ZIP_TIMER = .200 # time give to player to zip up before falling again
const RELEASE_TIMER = .100 # time give to player to zip up before falling again
var zip_timer
var release_timer

var chain_pull
var chain_velocity = Vector2(0,0)
var zip_state
var chain_set

func enter():
	chain_set = false
	zip_state = false
	release_timer = RELEASE_TIMER
	zip_timer = ZIP_TIMER

	chain_pull = CHAIN_STRENGTH_SLOW

	if owner.hook_dir == Vector2(): # if no input on enter
		owner.hook_dir = owner.look_direction

	owner.get_node("chain").shoot(owner.hook_dir)
	owner.velocity *= PLAYER_ENTER_SLOWDOWN
	connect("setup_done_chain", self, "set_chain")

func update(delta):
	release_timer -= delta
	if Input.is_action_pressed("jump") and release_timer < 0: # bugs if jumping same frame as press
		emit_signal("finished", "previous")
	elif not Input.is_action_pressed("hook"): # window to zip up
		zip_timer -= delta
		if zip_timer < 0:
			emit_signal("finished", "previous")
		return

#	if chain_set:
#		owner.global_position = owner.get_node("chain").end_loop.global_position
#		print(owner.get_node("chain").end_loop)
#		print("glob ", owner.global_position)
#		print("Hook",owner.get_node("chain").end_loop.global_position) #global position here does not update when chains moves on its own
#		#zipup
#		if Input.is_action_just_pressed("hook"):
#			chain_pull = CHAIN_STRENGTH_FAST
#			zip_state = true
#		else: #
#			chain_velocity = (owner.get_node("chain").get_node("tip").position).normalized() * chain_pull
#			#important else gravity going to stack with pulldown, drop velocity drops very fast
#			if chain_velocity.y > 0:
#				chain_velocity.y *= PULL_DOWN_STRENGTH
#			else:
#				chain_velocity.y *= PULL _UP_STRENGTH
#	else:
#		chain_velocity = Vector2(0,0)
#
##	if zip_state == true:
##		owner.velocity = chain_velocity
##	else:
##		owner.velocity.y += owner.GRAVITY * delta # normal gravity when player not hooked yet
#
#	owner.move_and_slide(owner.velocity, Vector2.UP)

	owner.velocity.y = clamp(owner.velocity.y, -MAX_SPEED, MAX_SPEED)
	owner.velocity.x = clamp(owner.velocity.x, -MAX_SPEED, MAX_SPEED)

func exit():
	owner.get_node("chain").release()


func _on_chain_dangling_setup_done():
	chain_set = true
