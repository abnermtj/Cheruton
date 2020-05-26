extends motionState

const GROUND = 0
const AIR = 1
const ATTACK_TIMER_BUFFER = .36
const GRAVITY_MULTIPLIER =.1

const GROUND_SPEED_H_1 = 200
const GROUND_SPEED_H_2 = 890
const GROUND_SPEED_H_3 = 2000

const AIR_SPEED_H_1 = 200
const AIR_SPEED_H_2 = 1000

var attack_timer
var attack_count
var attack_type
var attack_again
var charge_dir
var updated_once = false
var enter_vel

func enter():
	if get_parent().previous_state is groundState:
		owner.play_anim("attack_ground_1") # change to later on
		attack_type = GROUND
		owner.velocity = Vector2(owner.look_direction.x*GROUND_SPEED_H_1,500)
	else:
		owner.play_anim("attack_air_1")
		owner.velocity.x = owner.look_direction.x*AIR_SPEED_H_1
		attack_type = AIR

	attack_count = 0
	attack_again = false
	attack_timer = ATTACK_TIMER_BUFFER
	updated_once = false
	enter_vel = owner.velocity

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
		owner.velocity.x *= .9 # decay so make the speed more poppy
		match attack_count:
			0:
				if attack_again == true and attack_timer < 0:
					owner.velocity = Vector2(input_dir.x*GROUND_SPEED_H_2,500)
					attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false
					owner.queue_anim("attack_ground_2")
					update_look_direction(input_dir)

			1:# second attack

				if attack_again == true and attack_timer < 0:
					owner.queue_anim("attack_ground_3")
					owner.queue_anim_fx("attack_ground_3")
					attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false

			2: #third attack
				attack_count += 1
				update_look_direction(input_dir)
				owner.queue_anim("attack_ground_3")
				owner.velocity = Vector2(owner.look_direction.x*GROUND_SPEED_H_3,5)
				charge_dir = input_dir.x
			3:

				if attack_timer< 0:
					emit_signal("finished", "run")
					return

	elif attack_type == AIR:
		owner.velocity.x *= .9
		owner.velocity.y *= .82
		match attack_count:
			0:
				if attack_again == true and attack_timer < 0:
					owner.velocity.x = input_dir.x*AIR_SPEED_H_2
					attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false

			1:
				attack_count += 1
				update_look_direction(input_dir)
				owner.queue_anim("attack_air_2")

			2:
				if attack_timer< 0:
					if owner.is_on_floor():
						emit_signal("finished", "run")
					else:
						emit_signal("finished", "fall")
	owner.move()
	updated_once = true

func update_idle(delta):
	pass
