extends baseGui

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"

#exiting to mm/exit needs to warn player about unsaved data
func _on_ExitDirect_pressed():
	DataResource.save_player()
	get_tree().quit()

func _on_Settings_pressed():
	emit_signal("new_gui", "settings")

func _on_RMMenu_pressed():
	LoadGlobal.goto_scene(MAINMENU)

func _on_ExitPause_pressed():
	DataResource.save_player()
	emit_signal("release_gui", "pause")

func handle_input(event):
	if is_active_gui and Input.is_action_just_pressed("escape"):
		_on_ExitPause_pressed()
