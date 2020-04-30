extends Control

var health_max

func _ready():	
	DataResource.connect("loaded", self, "initbar")
	DataFunctions.connect("increase_health", self, "increase_healthbar")
	DataFunctions.connect("decrease_health", self, "decrease_healthbar")
	


func initbar():
	
	var old_health = DataResource.dict_player["health_curr"]
	health_max = DataResource.dict_player["health_max"]
	if(health_max != 0):
		$HealthBar.value = old_health/health_max * 100

func increase_healthbar(new_health):
	animate_healthbar($HealthBar.value, new_health/health_max * 100)
	
func decrease_healthbar(new_health):
	animate_healthbar($HealthBar.value, new_health/health_max * 100)


func animate_healthbar(start, end):
	$Tween.interpolate_property($HealthBar, "value", start, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
