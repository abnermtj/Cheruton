extends Control

onready var healthbar_fast = $HealthBarFast
onready var healthbar_slow = $HealthBarSlow

var max_health : float
var goal_health : float
var changing = false
var change_speed : float


func init_bar(max_value) -> void:
	healthbar_slow.max_value = max_value
	healthbar_slow.value = max_value

	healthbar_fast.max_value = max_value
	healthbar_fast.value = max_value

	max_health = max_value

func animate_healthbar(end) -> void:
	healthbar_fast.value = end
	goal_health = end

	if not changing:
		changing = true
		change_speed = 1

func _process(delta):
	if changing:
		change_speed = lerp(change_speed, max_health / 5, delta/5)
		healthbar_slow.value += change_speed * sign(goal_health - healthbar_slow.value)

		if healthbar_slow.value < goal_health: # need to change logic for healing mobs
			changing = false
			healthbar_slow.value = healthbar_fast.value
