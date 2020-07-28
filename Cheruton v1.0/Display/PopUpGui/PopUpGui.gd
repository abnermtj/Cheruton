extends CanvasLayer

onready var popups = $popUps
var enabled = false setget set_gui_enabled

func set_gui_enabled(val):
	popups.active = val
	popups.visible = val
	if val == false:
		get_tree().paused = false # if disabling from pause menu
		popups.reset()

func dialog_only():
	for entry in popups.pop_up_enable_list:
		if entry == "dialog":
			popups.pop_up_enable_list[entry] = true
		else:
			popups.pop_up_enable_list[entry] = false

func end_dialog_only():
	for entry in popups.pop_up_enable_list:
		popups.pop_up_enable_list[entry] = true
