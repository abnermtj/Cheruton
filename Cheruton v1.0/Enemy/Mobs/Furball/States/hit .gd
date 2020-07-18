extends baseState

const HURT_TIME = .5
const FREEZE_TIME = .04

var move_dir : Vector2
var initial_speed : float = 1000
var timer : float

func enter():
	owner.return_to_sleep = false
	owner.display_damage(owner.damage)
	owner.play_hit_effect()
	owner.health -= owner.damage

	owner.play_anim("hit")
	owner.play_anim_fx("hit")

	var obj_pos = owner.hitter.global_position
	move_dir = (owner.global_position - obj_pos ).normalized()
	owner.shake_camera(.05, 20.0, 19.5, -move_dir) # dur, freq, amp, dir
	owner.velocity.x = move_dir.x * initial_speed
	owner.look_dir = Vector2(-sign(move_dir.x),0)

	timer = HURT_TIME
	get_tree().paused = true

func update(delta):
	timer -= delta
	if timer < 0:
		owner.velocity.y = 0
		emit_signal("finished", "fall")

	owner.velocity.x = lerp(owner.velocity.x,0 , delta * 3)
	owner.velocity.y = clamp(owner.velocity.y + owner.GRAVITY / 2 * delta, -INF, owner.TERMINAL_VELOCITY)

	if timer < HURT_TIME - FREEZE_TIME: # game juice freeze
		get_tree().paused = false
	if timer < HURT_TIME - .1:
		owner.move()
