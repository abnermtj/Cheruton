extends Node

const PAUSE = preload("res://Display/Pause/Pause.tscn")
#need to disable keyboard input at welcome, mmenu settings
func _input(ev): # need to fix first
	if Input.is_key_pressed(KEY_ESCAPE):
		# Instance the new scene.
		var current_scene = PAUSE.instance()
		PAUSE.popup()
