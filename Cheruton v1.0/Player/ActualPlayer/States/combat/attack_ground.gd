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

func enter():
	attack_again = false


	var input_dir = get_input_direction()
	owner.look_direction = input_dir

	attack_type = GROUND if (owner.prev_state is groundState) else AIR

	owner.attack_count += 1
	if attack_type == GROUND:
		match owner.attack_count:
			1:
				owner.velocity = Vector2(owner.look_direction.x*GROUND_SPEED_H_1,500)
				owner.play_anim("attack_ground_1")

			2:
				owner.velocity = Vector2(input_dir.x*GROUND_SPEED_H_2, 500)
				owner.play_anim("attack_ground_2")

			3:
				owner.velocity = Vector2(input_dir.x*GROUND_SPEED_H_3, 5)

				owner.play_anim("attack_ground_3")
				if input_dir.x:
					owner.play_anim_fx("attack_ground_3")

				owner.can_attack = false

			4:
				emit_signal("finished", "run")

	elif attack_type == AIR:
		match owner.attack_count:
			1:
				owner.velocity.x = owner.look_direction.x*AIR_SPEED_H_1
				owner.play_anim("attack_air_1")
			2:
				owner.velocity.x = input_dir.x*AIR_SPEED_H_2

				owner.play_anim("attack_air_2")
				owner.play_anim_fx("attack_air_2")
			3:
				owner.velocity.x = input_dir.x*AIR_SPEED_H_3

				owner.play_anim("attack_air_3")
				owner.play_anim_fx("attack_air_3")

				owner.can_attack = false

			4:
				emit_signal("finished", "fall")

	attack_timer = ATTACK_TIMER_BUFFER

func update(delta):
	attack_timer -= delta

	if Input.is_action_just_pressed("attack") and attack_timer < ATTACK_TIMER_BUFFER/ 2:
		attack_again = true

	if attack_timer < 0 and attack_again == false:
		emit_signal("finished", "run")
		return

	if attack_timer < 0 and attack_again == true:
		enter()

	# decays to make intial velocity seem fast
	if attack_type == GROUND:
		owner.velocity.x *= .9
	elif attack_type == AIR:
		owner.velocity.x *= .9
		owner.velocity.y *= .82

	owner.move()
