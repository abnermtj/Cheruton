extends Control

const SCN1 = "res://Levels/Hometown/Hometown.tscn"
var SETTINGS = preload("res://Display/Settings/Settings.tscn")

func _ready():
	DataResource.dict_settings["game_on"] = false


func _on_Play_pressed():
	LoadScrnGlobal.goto_scene(SCN1)
	DataResource.dict_settings.maj_scn = false
	DataResource.dict_settings.game_on = true
func _on_Settings_pressed():
	var curr_scene = SETTINGS.instance()
	DataResource.current_scene.hide()
	get_tree().get_root().add_child(curr_scene)

func _on_Exit_pressed():
	#DataResource.save_player() #- can save before going back to mm??
	get_tree().quit()



