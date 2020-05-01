extends Control

var health_max

func _ready():	
	#change loaded to when press play
	DataResource.connect("loaded", self, "initbar")
	DataFunctions.connect("increase_health", self, "increase_healthbar")
	DataFunctions.connect("decrease_health", self, "decrease_healthbar")
	

func initbar():
	var old_health = DataResource.dict_player["health_curr"]
	health_max = DataResource.dict_player["health_max"]
	if(health_max != 0):
		$HealthBar.value = old_health/health_max * 100
	$HealthVal.text = str(DataResource.dict_player["health_curr"], "/",DataResource.dict_player["health_max"])
	
func increase_healthbar(new_health):
	animate_healthbar($HealthBar.value, new_health/health_max * 100)
	
func decrease_healthbar(new_health):
	animate_healthbar($HealthBar.value, new_health/health_max * 100)


func animate_healthbar(start, end):
	$Tween.interpolate_property($HealthBar, "value", start, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	


func _on_HealthBar_value_changed(value):
	$HealthVal.text = str(int($HealthBar.value * health_max/100), "/", health_max)
	if(value > 49):
		$HealthBar.set_tint_progress(Color(0.180392, 0.415686, 0.258824))
	elif(value > 19):
		$HealthBar.set_tint_progress(Color(0.968627, 0.67451, 0.215686))
	else:
		$HealthBar.set_tint_progress(Color(0.768627, 0.172549, 0.211765))
