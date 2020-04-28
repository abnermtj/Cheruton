extends Node

signal update_signal(new_exp, new_exp_max)

func add_exp(var exp_gain):
	DataResource.dict_player["exp_curr"] += exp_gain
	
	# Next Level Reached
	if(DataResource.dict_player["exp_curr"] >= DataResource.dict_player["exp_max"]):
		DataResource.dict_player["level"] += 1
		DataResource.dict_player["exp_curr"] -= DataResource.dict_player["exp_max"]
		DataResource.dict_player["exp_max"] *= 1.5
	
	emit_signal("update_signal", DataResource.dict_player["exp_curr"], DataResource.dict_player["exp_max"])
