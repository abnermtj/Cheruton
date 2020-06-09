extends Control

onready var healthbar = $HealthRect/HealthBar

var health_max

func _ready():	
	connect("change_enemy_health", self, "change_healthbar")

	

func initbar():
	health_max = 400
	healthbar.value = 100
	

func change_healthbar(new_health):
	animate_healthbar(healthbar.value, new_health/health_max * 100)


func animate_healthbar(start, end):
	$Tween.interpolate_property(healthbar, "value", start, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
