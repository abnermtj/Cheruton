extends Node

signal update_exp(new_exp, new_exp_max, new_level)
signal increase_health(new_health)
signal decrease_health(new_health)

#const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"
#const WELCOME = "res://Display/Welcome/Welcome.tscn"
const PAUSE = "res://Display/Pause/Pause.tscn"

func add_exp(var exp_gain):
	DataResource.dict_player["exp_curr"] += exp_gain
	
	# Next Level Reached
	if(DataResource.dict_player["exp_curr"] >= DataResource.dict_player["exp_max"]):
		DataResource.dict_player["level"] += 1
		DataResource.dict_player["exp_curr"] -= DataResource.dict_player["exp_max"]
		DataResource.dict_player["exp_max"] *= 1.5
	
	emit_signal("update_exp", DataResource.dict_player["exp_curr"], DataResource.dict_player["exp_max"], DataResource.dict_player["level"])

func add_health(var health_gain):
	DataResource.dict_player["health_curr"] += health_gain
	if(DataResource.dict_player["health_curr"] > DataResource.dict_player["health_max"]):
		DataResource.dict_player["health_curr"] = DataResource.dict_player["health_max"]	
	
	emit_signal("increase_health", DataResource.dict_player["health_curr"])

func lose_health(var health_loss):
	DataResource.dict_player["health_curr"] -= health_loss
	if(DataResource.dict_player["health_curr"] < 0):
		DataResource.dict_player["health_curr"] = 0
	
	emit_signal("decrease_health", DataResource.dict_player["health_curr"])

#need to disable keyboard input at welcome, mmenu settings
func _input(ev):
	if Input.is_key_pressed(KEY_ESCAPE):
		LoadGlobal.goto_scene(PAUSE)

