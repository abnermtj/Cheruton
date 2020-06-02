wextends Node

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"
func _ready():
	DataResource.load_data()
	DataResource.dict_settings["game_on"] = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), DataResource.dict_settings.is_mute)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), DataResource.dict_settings.audio)
	#Cursor.init_cursor()
	#Testing loot functionality
	Loot.determine_loot("test")


func _on_Timer_timeout():
	LoadGlobal.goto_scene(MAINMENU)
