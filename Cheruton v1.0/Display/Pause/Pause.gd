extends Popup

var SETTINGS = preload("res://Display/Settings/Settings.tscn")

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"

func _ready():
	DataResource.dict_settings["game_on"] = false

#exiting to mm/exit needs to warn player about unsaved data


func _on_ExitDirect_pressed():
	get_tree().quit()



func _on_Settings_pressed():
	DataResource.dict_settings.maj_scn = true
	DataResource.current_scene.hide()
	DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1).hide()
	var curr_scene = SETTINGS.instance()
	get_tree().get_root().add_child(curr_scene)


func _on_RMMenu_pressed():
	DataResource.dict_settings.maj_scn = true
	LoadGlobal.goto_scene(MAINMENU)

func _on_ExitPause_pressed():
	free_the_pause()
	KeyPress.last_key = null


func free_the_pause():
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()
	yield(get_tree().create_timer(0.2), "timeout")
	DataResource.dict_settings.game_on = true


