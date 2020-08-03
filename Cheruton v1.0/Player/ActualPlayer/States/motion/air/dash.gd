extends airState

const VELOCITY = 500
const OFFSET_FROM_SWORD_POS = 65

var dir : Vector2

func handle_input(event): # disables all inputs
	pass

func enter():
	var normal = owner.sword_col_normal
	owner.look_direction = -normal
	owner.velocity =  (owner.sword_pos - owner.global_position).normalized() * VELOCITY
	owner.global_position = owner.sword_pos + OFFSET_FROM_SWORD_POS * normal

	owner.play_anim("pull_weapon")
	owner.queue_anim("fall") # need to an queue anim else it won't trigger animation finished signal

func update(delta):
	owner.move()

func _on_animation_finished(anim_name):
	if anim_name == "pull_weapon":
		emit_signal("finished", "fall")
