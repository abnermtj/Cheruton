extends Node

signal update_exp(new_exp, new_exp_max, new_level)
signal change_health(new_health)

signal change_audio_master

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"
const WELCOME = "res://Display/Welcome/Welcome.tscn"
const SETTINGS = "res://Display/Settings/Settings.tscn"
const LOAD_SCRN = "res://Display/LoadScrn/LoadScrn.tscn"

func add_exp(var exp_gain):
	DataResource.temp_dict_player.exp_curr += exp_gain

	# Next Level Reached
	if(DataResource.temp_dict_player.exp_curr >= DataResource.temp_dict_player.exp_max):
		DataResource.temp_dict_player.level += 1
		DataResource.temp_dict_player.exp_curr -= DataResource.temp_dict_player.exp_max
		DataResource.temp_dict_player.exp_max *= 1.5

	emit_signal("update_exp", DataResource.temp_dict_player.exp_curr, DataResource.temp_dict_player.exp_max, DataResource.temp_dict_player.level)

func change_health(var health_change):
	DataResource.temp_dict_player.health_curr = clamp(DataResource.temp_dict_player.health_curr + health_change, 0, DataResource.temp_dict_player.health_max)
	emit_signal("change_health", DataResource.temp_dict_player.health_curr)

func change_coins(coins_change):
	DataResource.temp_dict_player.coins += coins_change


func change_audio_master(var audio_change):
	DataResource.dict_settings.audio = clamp(DataResource.dict_settings.audio + audio_change, -60, 12)
	print(DataResource.dict_settings.audio)
	emit_signal("change_audio_master")

#beta
#func anim_foilage(scene):
#	pass
