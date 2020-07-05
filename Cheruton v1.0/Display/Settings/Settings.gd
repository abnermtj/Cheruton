extends basePopUp

onready var main_bar = $ContainerMain/List/MainVol/MainVolBar
onready var music_bar = $ContainerMain/List/MusicVol/MusicVolBar
onready var sfx_bar = $ContainerMain/List/SFXVol/SFXVolBar
onready var list = $ContainerMain/List

func _ready():
	init_bar_vals()
	connect_functions()

func init_bar_vals():
	main_bar.value = (DataResource.dict_settings.audio_master + 60) / 60 * 100
	music_bar.value = (DataResource.dict_settings.audio_music + 60) / 60 * 100
	sfx_bar.value = (DataResource.dict_settings.audio_sfx + 60) / 60 * 100

func connect_functions():
	var _conn1 = DataResource.connect("change_audio_master", self, "change_master_vol")
	var _conn2 = DataResource.connect("change_audio_music", self, "change_music_vol")
	var _conn3 = DataResource.connect("change_audio_sfx", self, "change_sfx_vol")

func _on_MuteToggle_pressed():
	DataResource.dict_settings.is_mute = !DataResource.dict_settings.is_mute
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), DataResource.dict_settings.is_mute)

func change_master_vol():
	main_bar.value = (DataResource.dict_settings.audio_master + 60) / 60 * 100

func change_music_vol():
	music_bar.value = (DataResource.dict_settings.audio_music + 60) / 60 * 100

func change_sfx_vol():
	sfx_bar.value = (DataResource.dict_settings.audio_sfx + 60) / 60 * 100

func _on_MainVolUp_pressed():
	DataResource.change_audio_master(6)

func _on_MainVolDown_pressed():
	DataResource.change_audio_master(-6)

func _on_MusicVolUp_pressed():
	DataResource.change_audio_music(6)

func _on_MusicVolDown_pressed():
	DataResource.change_audio_music(-6)

func _on_SFXVolUp_pressed():
	DataResource.change_audio_sfx(6)

func _on_SFXVolDown_pressed():
	DataResource.change_audio_sfx(-6)

#change this to go back to previously loaded scene
func _on_Back_pressed():
	DataResource.save_rest() # so that the new settings persist on next save file
	emit_signal("release_gui", "settings")


func handle_input(event):
	if is_active_gui and Input.is_action_just_pressed("escape"):
		_on_Back_pressed()



