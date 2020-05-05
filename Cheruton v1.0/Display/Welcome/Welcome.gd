extends Node

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"
func _ready():
	DataResource.load_player()
	DataResource.load_settings()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), DataResource.dict_settings["audio"])
	
	
func _on_Timer_timeout():
	LoadGlobal.goto_scene(MAINMENU)
