extends Node

signal update_mainvol

func _ready():
	$MainVol/MainVolBar.value = (10 - ((10 - DataResource.dict_settings["audio"])/8)) * 10
	


func _on_MuteToggle_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))))


func _on_MainVolUp_pressed():
	if($MainVol/MainVolBar.value != 100): 
		DataResource.dict_settings["audio"]+= 8
		# change to change_audio_val

func _on_MainVolDown_pressed():
	if($MainVol/MainVolBar.value != 0): 
		DataResource.dict_settings["audio"]-= 8
