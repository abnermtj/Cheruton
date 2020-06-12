extends baseState

const JUMP_TIME = 1.0
const JUMP_HEIGHT = 1000
const JUMP_TRACK_SPEED = 30
const GRAVITY = 300
const INITIAL_VEL_DOWN = Vector2(0,50)

var fall_timer

enum jump_states {JUMP =0, FALL =1, LAND = 2}
var cur_state

func enter():
	owner.hide()
	fall_timer = JUMP_TIME
	cur_state = jump_states.JUMP

func update(delta):
	match cur_state:
		jump_states.JUMP:
			var dir = (DataResource.dict_player.player_pos - owner.global_position).normalized()
			owner.velocity = dir * JUMP_TRACK_SPEED
			fall_timer -= delta
			if fall_timer < 0:
				owner.position.y -= JUMP_HEIGHT
				owner.velocity = INITIAL_VEL_DOWN
				cur_state = jump_states.FALL
			owner.move()
		jump_states.FALL:
			owner.play_anim("jump_attack_fall")
			cur_state = jump_states.LAND
		jump_states.LAND:
			owner.show()
			owner.move()
			owner.velocity.y += GRAVITY
			if owner.is_on_floor():
				emit_signal("finished", "idle")
	.update(delta)




