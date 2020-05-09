extends Node


onready var PAUSE = preload("res://Display/Pause/Pause.tscn")
onready var INVENTORY = preload("res://Player/Inventory/Inventory.tscn")

#fix key closure to close only with assigned key! - find better check than getchild
func _input(ev):
	if Input.is_key_pressed(KEY_ESCAPE):

		if (DataResource.dict_settings["game_on"] == true):
			instance_scene(PAUSE)
			DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1).popup()
		else:
			free_scene()

	elif Input.is_key_pressed(KEY_I):
		if (DataResource.dict_settings["game_on"] == true):
			instance_scene(INVENTORY)
		else:
			free_scene()

func instance_scene(NEW):
	var curr_scene = NEW.instance()
	DataResource.current_scene.add_child(curr_scene)


func free_scene():
	DataResource.dict_settings["game_on"] = true
	var instanced_scene = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	if(instanced_scene):
		instanced_scene.queue_free()
