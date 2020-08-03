extends motionState

const GROUND = 0
const AIR = 1
const ATTACK_TIMER_BUFFER = .36
const GRAVITY_MULTIPLIER =.1

const GROUND_SPEED_H_1 = 400
const GROUND_SPEED_H_2 = 890
const GROUND_SPEED_H_3 = 2000

const AIR_SPEED_H_1 = 200
const AIR_SPEED_H_2 = 1100
const AIR_SPEED_H_3 = 1640

var attack_timer : float
var attack_type : int
var attack_again : bool
var charge_dir : int
var updated_once = false
var enter_vel : Vector2

func enter():
	attack_type = GROUND if (owner.prev_state is groundState) else AIR

	attack_again = false
	attack_timer = ATTACK_TIMER_BUFFER
	updated_once = false # otherwise attack input triggered twice from initial call
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
		owner.velocity.x *= .9 # decay to make intial seem fast
		match owner.attack_count:
			0:
				owner.attack_count += 1
				owner.play_anim("attack_ground_1")
				owner.velocity = Vector2(owner.look_direction.x*GROUND_SPEED_H_1,500)

			1: if attack_again and attack_timer < 0:
					owner.attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false

					owner.velocity = Vector2(input_dir.x*GROUND_SPEED_H_2,500)

					owner.play_anim("attack_ground_2")
					owner.look_direction = input_dir

			2:
				if attack_again and attack_timer < 0:
					owner.attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false

					charge_dir = input_dir.x
					owner.velocity = Vector2(input_dir.x*GROUND_SPEED_H_3,5)

					owner.play_anim("attack_ground_3")
					if input_dir.x:
						owner.play_anim_fx("attack_ground_3")

					owner.look_direction = input_dir
			3:
				if attack_timer< 0:
					owner.can_attack = false
					emit_signal("finished", "run")
					return

	elif attack_type == AIR:
		owner.velocity.x *= .9
		owner.velocity.y *= .82
		match owner.attack_count:
			0:
				owner.attack_count += 1
				owner.play_anim("attack_air_1")
				owner.velocity.x = owner.look_direction.x*AIR_SPEED_H_1
			1:
				if attack_again and attack_timer < 0:
					owner.attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false

					owner.velocity.x = input_dir.x*AIR_SPEED_H_2

					owner.play_anim("attack_air_2")
					owner.play_anim_fx("attack_air_2")
					owner.look_direction = input_dir

			2:
				if attack_again and attack_timer < 0:
					owner.attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false

					owner.velocity.x = input_dir.x*AIR_SPEED_H_3

					owner.play_anim("attack_air_3")
					owner.play_anim_fx("attack_air_3")
					owner.look_direction = input_dir

			3:
				if attack_timer< 0:
					owner.can_attack = false
					if owner.is_on_floor():
						emit_signal("finished", "run")
					else:
						emit_signal("finished", "fall")
	owner.move()
	updated_once = true
