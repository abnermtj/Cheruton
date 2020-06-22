extends Control

const SCN1 = "res://Levels/Hometown/Hometown.tscn"
const EXPBAR = "HudLayer/Hud/StatBars/ExpBar"
const HEALTHBAR = "HudLayer/Hud/StatBars/HealthBar"

onready var SETTINGS = $Settings
onready var scene_control = self.get_parent().get_parent()


func _ready():
	LevelguiMaster.enabled = false
	SETTINGS.hide()
	SETTINGS.connect("release_gui", self, "_exit_Settings")

func _on_Play_pressed():
#	scene_control.get_node(HEALTHBAR).init_bar()
#	scene_control.get_node(EXPBAR).init_bar()
	
	scene_control.load_screen(SCN1, true, true)
func _on_Settings_pressed():
	SETTINGS.show()
func _exit_Settings(gui_name):
	SETTINGS.hide()

func _on_Exit_pressed():
	get_tree().quit()

