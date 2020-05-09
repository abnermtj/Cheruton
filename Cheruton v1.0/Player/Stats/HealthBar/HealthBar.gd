extends Control

var health_max

func _ready():	
	DataFunctions.connect("change_health", self, "change_healthbar")

	

func initbar():
	var old_health = DataResource.dict_player["health_curr"]
	health_max = DataResource.dict_player["health_max"]
	$HealthRect/HealthBar.value = old_health/health_max * 100
	$HealthRect/HealthStats/HealthVal.text = str(DataResource.dict_player["health_curr"], "/",DataResource.dict_player["health_max"])
	
func change_healthbar(new_health):
	if(new_health < 0):
		new_health = 0
	animate_healthbar($HealthRect/HealthBar.value, new_health/health_max * 100)


func animate_healthbar(start, end):
	$Tween.interpolate_property($HealthRect/HealthBar, "value", start, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	


func _on_HealthBar_value_changed(value):
	$HealthRect/HealthStats/HealthVal.text = str(floor($HealthRect/HealthBar.value * health_max/100), "/", health_max)
	if(value > 49):
		$HealthRect/HealthBar.set_tint_progress(Color(0.180392, 0.415686, 0.258824))
	elif(value > 19):
		$HealthRect/HealthBar.set_tint_progress(Color(0.968627, 0.67451, 0.215686))
	else:
		$HealthRect/HealthBar.set_tint_progress(Color(0.768627, 0.172549, 0.211765))
