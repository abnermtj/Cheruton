extends Node


onready var PAUSE = preload("res://Display/Pause/Pause.tscn")
onready var INVENTORY = preload("res://Player/Inventory/Inventory_new.tscn")#stub

var last_key

#fix key closure to close only with assigned key! - find better check than getchild
func _input(_ev):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if(DataResource.dict_settings.maj_scn == false):
		if Input.is_key_pressed(KEY_ESCAPE):
			yield(get_tree().create_timer(0.01), "timeout")
			if (DataResource.dict_settings.game_on == true):
				instance_scene(PAUSE)
				DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1).popup()
				last_key = KEY_ESCAPE
			elif(last_key == KEY_ESCAPE):
				free_scene()
				last_key = null

		elif Input.is_key_pressed(KEY_I):
			yield(get_tree().create_timer(0.01), "timeout")
			if (DataResource.dict_settings.game_on == true):
				instance_scene(INVENTORY)
				last_key = KEY_I
			elif(last_key == KEY_I):
				free_scene()
				last_key = null



func instance_scene(NEW):
	var curr_scene = NEW.instance()
	DataResource.current_scene.add_child(curr_scene)


func free_scene():
	DataResource.dict_settings.game_on = true
	var instanced_scene = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	if(instanced_scene):
		instanced_scene.queue_free()
