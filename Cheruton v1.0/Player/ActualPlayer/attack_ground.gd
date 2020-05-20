extends motionState

const GROUND = 0
const AIR = 1
const ATTACK_TIMER_BUFFER = .2

var attack_timer
var attack_count
var attack_type
var attack_again

func enter():
	if owner.on_floor:
		owner.play_anim("attack_ground") # change to later on
		attack_type = GROUND
	else:
		owner.play_anim("attack_air")
		attack_type = AIR
	attack_count = 0
	attack_again = false
	attack_timer = ATTACK_TIMER_BUFFER

# 3 hit combo
func update(delta):
	attack_timer -= delta

	if Input.is_action_just_pressed("attack") and attack_timer > 0:
		attack_again = true

	if attack_timer < 0 and attack_again == false:
		emit_signal("finsihed", "previous")
		return

	if attack_type == GROUND:
		match attack_count:
			0,1:
				if attack_again == true and attack_timer < 0:
					attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false
			2:
				if attack_timer< 0:
					emit_signal("finsihed", "previous")


	elif attack_type == AIR:
		owner.velocity = Vector2()
		match attack_count:
			0:
				if attack_again == true and attack_timer < 0:
					attack_count += 1
					attack_timer = ATTACK_TIMER_BUFFER
					attack_again = false
			1:
				if attack_timer< 0:
					emit_signal("finsihed", "previous")
	owner.move()


