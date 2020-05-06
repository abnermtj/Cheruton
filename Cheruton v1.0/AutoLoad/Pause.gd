extends Popup

const SETTINGS = "res://Display/Settings/Settings.tscn"
const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"

func _ready():
	DataResource.dict_settings["game_on"] = false

func _on_ExitDirect_pressed():
	#save player_data?
	get_tree().quit()


func _on_Settings_pressed():
	LoadGlobal.goto_scene(SETTINGS)
	

func _on_RMMenu_pressed():
	LoadGlobal.goto_scene(MAINMENU)

func _on_ExitPause_pressed():
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()
	DataResource.dict_settings["game_on"] = true
	KeyPress.paused_instance = false
	
