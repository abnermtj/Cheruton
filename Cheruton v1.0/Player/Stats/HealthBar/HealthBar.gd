extends Control


onready var healthbar = $HealthRect/HealthBarDesign/HealthBar
onready var healthstat = $HealthRect/HealthStats/HealthVal
#onready var heart = $HealthRect/HealthBarDesign/Heart

var health_max

func _ready():	
	DataFunctions.connect("change_health", self, "change_healthbar")
	SceneControl.connect("init_statbar", self, "init_bar")

func init_bar():
	var old_health = DataResource.temp_dict_player.health_curr
	health_max = DataResource.temp_dict_player.health_max
	healthbar.value = old_health/health_max * 100
	healthstat.text = str(DataResource.temp_dict_player.health_curr, "/",DataResource.temp_dict_player.health_max)

func change_healthbar(new_health):
	animate_healthbar(healthbar.value, new_health/health_max * 100)


func animate_healthbar(start, end):
	$Tween.interpolate_property(healthbar, "value", start, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	


func _on_HealthBar_value_changed(value):
	healthstat.text = str(floor(healthbar.value * health_max/100), "/", health_max)
	if(value > 49):
		healthbar.set_tint_progress(Color(0.180392, 0.415686, 0.258824))
	elif(value > 19):
		healthbar.set_tint_progress(Color(0.968627, 0.67451, 0.215686))
	else:
		healthbar.set_tint_progress(Color(0.768627, 0.172549, 0.211765))
		#heart.play("HeartBeatFast")
