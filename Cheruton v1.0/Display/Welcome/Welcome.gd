extends Node

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"
func _ready():
	DataResource.load_data()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), DataResource.dict_settings.is_mute)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), DataResource.dict_settings.audio_master)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), DataResource.dict_settings.audio_music)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), DataResource.dict_settings.audio_sfx)
	#Cursor.init_cursor()
	#Testing loot functionality
	LevelguiMaster.enabled = false

	Loot.determine_loot("test")

func _on_Timer_timeout():
	LoadGlobal.goto_scene(MAINMENU)

