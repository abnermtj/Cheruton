extends Node

var curr_scene
const PAUSE = preload("res://Display/Pause/Pause.tscn")



#need to disable keyboard input at welcome, mmenu settings
func _input(ev): 

	if Input.is_key_pressed(KEY_ESCAPE):
		# Instance the new scene
		curr_scene = PAUSE.instance()
		DataResource.current_scene.add_child(curr_scene)
		curr_scene.popup()


