extends Node

const SCN1 = "res://Levels/testBench/playerTestBench.tscn"
const SCN2 = "res://Levels/Hometown/Hometown.tscn"
const SCN3 = "res://Levels/spiderBosstestBench/SpiderbossTestScene.tscn"
const EXPBAR = "HudLayer/Hud/StatBars/ExpBar"
const HEALTHBAR = "HudLayer/Hud/StatBars/HealthBar"

onready var settings = $Settings
onready var options = $Background/Main/Options
onready var timer_options = $Timer
onready var scene_control = get_parent().get_parent()

onready var bg_music_file 

func _ready():
	SceneControl.get_node("masterGui").enabled = false
	settings.connect("release_gui", self, "_exit_Settings")
	print(DataResource.dict_main)
	$Timer.start()

func _on_Play_pressed():
	scene_control.emit_signal("init_statbar")
	SceneControl.load_screen(SCN1, true, true)

func _on_Settings_pressed():
	options.hide()
	settings.show()

func _exit_Settings(gui_name):
	settings.hide()
	options.show()


func _on_Play2_pressed():
	scene_control.emit_signal("init_statbar")
	SceneControl.load_screen(SCN2, true, true)


func _on_Play3_pressed():
	scene_control.emit_signal("init_statbar")
	SceneControl.load_screen(SCN3, true, true)


func _on_Quit_pressed():
	get_tree().quit()


func _on_Timer_timeout():
	options.show()
