extends Node

signal update_exp(new_exp, new_exp_max, new_level)
signal change_health(new_health)
signal change_audio_master

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

func change_health(var health_change):
	DataResource.dict_player["health_curr"] += health_change
	if(DataResource.dict_player["health_curr"] > DataResource.dict_player["health_max"]):
		DataResource.dict_player["health_curr"] = DataResource.dict_player["health_max"]	

	elif(DataResource.dict_player["health_curr"] < 0):
		DataResource.dict_player["health_curr"] = 0
	
	emit_signal("change_health", DataResource.dict_player["health_curr"])
#To update the min and max vals
func change_audio_master(var audio_change):
	DataResource.dict_settings["audio"] += audio_change
	if(DataResource.dict_settings["audio"] > 20):
		DataResource.dict_settings["audio"] = 20	

	elif(DataResource.dict_settings["audio"] < -56):
		DataResource.dict_settings["audio"] = -56
	emit_signal("change_audio_master")


#need to disable keyboard input at welcome, mmenu settings
func _input(ev):
	if Input.is_key_pressed(KEY_ESCAPE):
		LoadGlobal.goto_scene(PAUSE)

