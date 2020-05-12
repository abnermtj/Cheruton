extends Node

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"
func _ready():
	DataResource.load_data()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), DataResource.dict_settings.is_mute)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), DataResource.dict_settings.audio)
	
	#Testing loot functionality
	var map = "test"
	var run = Loot.determine_loot_count(map)
	Loot.loot_selector(map, run)
	Loot.append_loot(map, run)

func _on_Timer_timeout():
	LoadGlobal.goto_scene(MAINMENU)
