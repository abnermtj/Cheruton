extends Node

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"
func _ready():
	DataResource.load_player()
	DataResource.load_settings()
	
	
func _on_Timer_timeout():
	LoadGlobal.goto_scene(MAINMENU)
