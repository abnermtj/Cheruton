extends Control

onready var healthbar_fast = $HealthBarFast
onready var healthbar_slow = $HealthBarSlow
onready var tween = $Tween

var max_health : float
var change_speed : float

func init_bar(max_value : float) -> void:
	healthbar_slow.max_value = max_value
	healthbar_slow.value = max_value

	healthbar_fast.max_value = max_value
	healthbar_fast.value = max_value

	max_health = max_value

func animate_healthbar(end : float) -> void:
	if end > healthbar_fast.value: # healing
		healthbar_slow.value = end
	else:
		tween.stop_all()
		tween.interpolate_property(healthbar_slow, "value", healthbar_slow.value, end, 1.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.start()

	healthbar_fast.value = end
