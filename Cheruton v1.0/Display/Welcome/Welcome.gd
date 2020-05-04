extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	DataResource.load_player()
	DataResource.load_settings()
	
	
func _on_Timer_timeout():
	LoadGlobal.goto_scene("res://Display/MainMenu/MainMenu.tscn")
