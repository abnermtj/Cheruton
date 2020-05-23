extends motionState

const GROUND = 0
const AIR = 1
const ATTACK_TIMER_BUFFER = .3
const GRAVITY_MULTIPLIER =.1

var attack_timer
var attack_count
var attack_type
var attack_again
var updated_once = false

func enter():
	if get_parent().previous_state is groundState:
		owner.play_anim("attack_ground_1") # change to later on
		attack_type = GROUND
	else:
		owner.play_anim("attack_air_1")
		attack_type = AIR

	attack_count = 0
	attack_again = false
	attack_timer = ATTACK_TIMER_BUFFER
	updated_once = false

# 3 hit combo
func update(delta):
	attack_timer -= delta

	if Input.is_action_just_pressed("attack") and attack_timer > 0 and updated_once:
		attack_again = true

	if attack_timer < 0 and attack_again == false:
		emit_signal("finished", "run")
		return

	var input_dir = get_input_direction()
	if attack_type == GROUND:
		owner.velocity = Vector2(input_dir.x*100,0)
		match attack_count:
			0,1:
				if attack_again == true and attack_timer < 0:
					attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false
					if attack_count == 1:
						update_look_direction(input_dir)
						owner.play_anim("attack_ground_2")

			2:
				update_look_direction(get_input_direction())
				owner.play_anim("attack_ground_3")
				if attack_timer< 0:
					emit_signal("finished", "run")


	elif attack_type == AIR:
		owner.velocity.y += owner.GRAVITY * GRAVITY_MULTIPLIER
		match attack_count:
			0:
				if attack_again == true and attack_timer < 0:
					attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false

			1:
				update_look_direction(input_dir)
				owner.play_anim("attack_air_2")
				if attack_timer< 0:
					emit_signal("finished", "fall")
	owner.move()
	updated_once = true

