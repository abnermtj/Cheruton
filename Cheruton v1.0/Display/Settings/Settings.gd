extends baseGui

func _ready():
	$MainVol/MainVolBar.value = (10 - ((10 - DataResource.dict_settings["audio"])/8)) * 10
	DataFunctions.connect("change_audio_master", self, "change_master_vol")

func _on_MuteToggle_pressed():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !(DataResource.dict_settings["is_mute"]))

func change_master_vol():
	$MainVol/MainVolBar.value = (10 - ((10 - DataResource.dict_settings["audio"])/8)) * 10

func _on_MainVolUp_pressed():
	DataFunctions.change_audio_master(8)


func _on_MainVolDown_pressed():
	DataFunctions.change_audio_master(-8)

#change this to go back to previously loaded scene
func _on_Back_pressed():
	DataResource.save_rest() # so that the new settings persist on next save file
	emit_signal("release_gui", "settings")


func handle_input(event):
	if is_active_gui and Input.is_action_just_pressed("escape"):
		_on_Back_pressed()
