extends Node

var paused_instance = false
const PAUSE = preload("res://Display/Pause/Pause.tscn")


#need to disable keyboard input at welcome, mmenu settings
func _input(ev): 
	if Input.is_key_pressed(KEY_P):
		#Prevents Multiple Instances
		if(paused_instance == false):	
			if (DataFunctions.prereq_pause() == false):
				return
			var curr_scene = PAUSE.instance()
			DataResource.current_scene.add_child(curr_scene)
			curr_scene.popup()
			paused_instance = true
