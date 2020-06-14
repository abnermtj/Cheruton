extends Node

signal update_exp(new_exp, new_exp_max, new_level)
signal change_health(new_health)

signal change_audio_master
signal change_audio_music
signal change_audio_sfx

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
	DataResource.dict_settings.audio_master = clamp(DataResource.dict_settings.audio_master + audio_change, -60, 12)
	emit_signal("change_audio_master")

func change_audio_music(var audio_change):
	DataResource.dict_settings.audio_music = clamp(DataResource.dict_settings.audio_music + audio_change, -60, 12)
	emit_signal("change_audio_music")

func change_audio_sfx(var audio_change):
	DataResource.dict_settings.audio_sfx = clamp(DataResource.dict_settings.audio_sfx + audio_change, -60, 12)
	emit_signal("change_audio_sfx")
