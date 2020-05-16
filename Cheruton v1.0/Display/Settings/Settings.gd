extends Node2D


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

#change this to go back to previously loaded scene
func _on_Back_pressed():
	var scene_to_free = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	scene_to_free.queue_free()
	DataResource.save_rest()
	if(KeyPress.last_key == KEY_ESCAPE):
		DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1).show()
		DataResource.dict_settings.maj_scn = false
	DataResource.current_scene.show()
