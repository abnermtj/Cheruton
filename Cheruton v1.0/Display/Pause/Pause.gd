extends Popup

const SETTINGS = "res://Display/Settings/Settings.tscn"
const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"

func _ready():
	pass

func _on_ExitDirect_pressed():
	get_tree().exit()


func _on_Settings_pressed():
	LoadGlobal.goto_scene(SETTINGS)


func _on_RMMenu_pressed():
	LoadGlobal.goto_scene(MAINMENU)
