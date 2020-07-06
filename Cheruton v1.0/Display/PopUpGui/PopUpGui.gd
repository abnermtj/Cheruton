extends CanvasLayer

var enabled = false setget set_gui_enabled

func set_gui_enabled(val):
	$popUps.active = val
	$popUps.visible = val
	if val == false:
		get_tree().paused = false # if disabling from pause menu
		$popUps.reset()
