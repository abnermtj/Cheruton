extends CanvasLayer

var enabled = true setget set_gui_enabled

func set_gui_enabled(val):
	$gui.active = val
	$gui.visible = val
	if val == false:
		get_tree().paused = false
		$gui.soft_reset()




