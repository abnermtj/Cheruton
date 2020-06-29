extends Control

const SCN1 = "res://Levels/testBench/playerTestBench.tscn"
const EXPBAR = "HudLayer/Hud/StatBars/ExpBar"
const HEALTHBAR = "HudLayer/Hud/StatBars/HealthBar"

onready var settings = $Settings
onready var button_list = $Buttons
onready var scene_control = self.get_parent().get_parent()


func _ready():
	SceneControl.get_node("masterGui").enabled = false
	settings.hide()
	settings.connect("release_gui", self, "_exit_Settings")

func _on_Play_pressed():
	scene_control.emit_signal("init_statbar")
	SceneControl.load_screen(SCN1, true, true)
	
func _on_Settings_pressed():
	button_list.hide()
	settings.show()

func _exit_Settings(gui_name):
	settings.hide()
	button_list.show()

func _on_Exit_pressed():
	get_tree().quit()

