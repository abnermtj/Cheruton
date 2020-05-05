extends Popup
signal free_pause
const SETTINGS = "res://Display/Settings/Settings.tscn"
const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"

func _ready():
	pass

func _on_ExitDirect_pressed():
	#save player_data?
	get_tree().quit()


func _on_Settings_pressed():
	emit_signal("free_pause")
	LoadGlobal.goto_scene(SETTINGS)
	

func _on_RMMenu_pressed():
	LoadGlobal.goto_scene(MAINMENU)

