extends Node

var current_scene



const PAUSE = preload("res://Display/Pause/Pause.tscn")
#need to disable keyboard input at welcome, mmenu settings
#fix the freeup and button press - buggy
func _input(ev): 
	Pause.connect("free_pause", self, "close_popup")
	if Input.is_key_pressed(KEY_ESCAPE):
		# Instance the new scene.
		DataResource.current_scene.hide()
		current_scene = PAUSE.instance()
		self.add_child(current_scene)
		current_scene.popup()

func close_popup():
	current_scene.queue_free()
