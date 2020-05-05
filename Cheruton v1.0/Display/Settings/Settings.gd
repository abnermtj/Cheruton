extends Node


func _ready():
	$MainVol/MainVolBar.value = (10 - ((10 - DataResource.dict_settings["audio"])/8)) * 10
	DataFunctions.connect("change_audio_master", self, "change_master_vol")


func _on_MuteToggle_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !(DataResource.dict_settings["is_mute"]))

func change_master_vol():
	$MainVol/MainVolBar.value = (10 - ((10 - DataResource.dict_settings["audio"])/8)) * 10

func _on_MainVolUp_pressed():
	DataFunctions.change_audio_master(8)


func _on_MainVolDown_pressed():
	DataFunctions.change_audio_master(-8)
