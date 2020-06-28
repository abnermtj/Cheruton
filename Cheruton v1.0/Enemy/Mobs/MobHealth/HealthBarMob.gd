extends Control

onready var healthbar = $HealthRect/HealthBar

func init_bar(max_value) -> void:
	healthbar.max_value = max_value # tbc
	healthbar.value = max_value

func animate_healthbar(start, end) -> void:
	$Tween.interpolate_property(healthbar, "value", start, end, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

