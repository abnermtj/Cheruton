extends Control

var health_max

func _ready():	
	DataFunctions.connect("change_health", self, "change_healthbar")

	

func initbar():
	var old_health = DataResource.temp_dict_player.health_curr
	health_max = DataResource.temp_dict_player.health_max
	$HealthRect/HealthBarDesign/HealthBar.value = old_health/health_max * 100
	$HealthRect/HealthStats/HealthVal.text = str(DataResource.temp_dict_player.health_curr, "/",DataResource.temp_dict_player.health_max)

func change_healthbar(new_health):
	animate_healthbar($HealthRect/HealthBarDesign/HealthBar.value, new_health/health_max * 100)


func animate_healthbar(start, end):
	$Tween.interpolate_property($HealthRect/HealthBarDesign/HealthBar, "value", start, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	


func _on_HealthBar_value_changed(value):
	$HealthRect/HealthStats/HealthVal.text = str(floor($HealthRect/HealthBarDesign/HealthBar.value * health_max/100), "/", health_max)
	if(value > 49):
		$HealthRect/HealthBarDesign/HealthBar.set_tint_progress(Color(0.180392, 0.415686, 0.258824))
	elif(value > 19):
		$HealthRect/HealthBarDesign/HealthBar.set_tint_progress(Color(0.968627, 0.67451, 0.215686))
	else:
		$HealthRect/HealthBarDesign/HealthBar.set_tint_progress(Color(0.768627, 0.172549, 0.211765))
		$HealthRect/HealthBarDesign/Heart.play("HeartBeatFast")
