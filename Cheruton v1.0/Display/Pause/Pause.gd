extends Popup

var SETTINGS = preload("res://Display/Settings/Settings.tscn")

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"

func _ready():
	DataResource.dict_settings["game_on"] = false

func _on_ExitDirect_pressed():
	#save player_data?
	get_tree().quit()


func _on_Settings_pressed():
	DataResource.current_scene.hide()
	var curr_scene = SETTINGS.instance()
	get_tree().get_root().add_child(curr_scene)


func _on_RMMenu_pressed():
	LoadGlobal.goto_scene(MAINMENU)

func _on_ExitPause_pressed():
	free_the_pause()


func _on_Pause_popup_hide():
	free_the_pause()

func free_the_pause():
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()
	DataResource.dict_settings["game_on"] = true

