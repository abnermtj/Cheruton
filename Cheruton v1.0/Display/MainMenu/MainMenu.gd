extends Control

#const SCN1 = "res://Empty.tscn"
const SCN1 = "res://Levels/Hometown/Hometown.tscn"
onready var SETTINGS = $Settings

func _ready():
	LevelguiMaster.enabled = false
	SETTINGS.hide()
	SETTINGS.connect("release_gui", self, "_exit_Settings")

func _on_Play_pressed():
	LoadScrnGlobal.goto_scene(SCN1)
func _on_Settings_pressed():
	SETTINGS.show()
func _exit_Settings(gui_name):
	SETTINGS.hide()

func _on_Exit_pressed():
	get_tree().quit()

