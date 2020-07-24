extends Control


onready var healthbar = $HealthBarDesign/HealthBar
onready var healthstat = $HealthBarDesign/HealthVal
onready var tween = $Tween

var health_max

func _ready():
	var _conn1 = DataResource.connect("change_health", self, "change_healthbar")
	var _conn2 = SceneControl.connect("init_statbar", self, "init_bar")

func init_bar():
	var old_health = DataResource.temp_dict_player.health_curr
	health_max = DataResource.temp_dict_player.health_max
	healthbar.value = old_health/health_max * 100
	healthstat.text = str(DataResource.temp_dict_player.health_curr, "/",DataResource.temp_dict_player.health_max)

func change_healthbar(new_health):
	animate_healthbar(healthbar.value, new_health/health_max * 100)

func animate_healthbar(start, end):
	tween.interpolate_property(healthbar, "value", start, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_HealthBar_value_changed(value):
	healthstat.text = str(floor(healthbar.value * health_max/100), "/", health_max)
	if(value > 49):
		healthbar.set_tint_progress(Color("#7bcf5c"))
	elif(value > 19):
		healthbar.set_tint_progress(Color("#e57028"))
	else:
		healthbar.set_tint_progress(Color("#c42c36"))
