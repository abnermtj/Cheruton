extends Node


onready var PAUSE = preload("res://Display/Pause/Pause.tscn")
onready var INVENTORY = preload("res://Player/Inventory/Inventory.tscn")

var last_key

#fix key closure to close only with assigned key! - find better check than getchild
func _input(ev):
	if(DataResource.dict_settings["maj_scn"] == false):
		print("non-major scene")
		if Input.is_key_pressed(KEY_ESCAPE):
			print("escape")
			if (DataResource.dict_settings["game_on"] == true):
				print("instanced pause")
				instance_scene(PAUSE)
				DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1).popup()
				last_key = KEY_ESCAPE
			elif(last_key == KEY_ESCAPE):
				print("released pause")
				free_scene()
				last_key = null

		elif Input.is_key_pressed(KEY_I):
			print("I")
			if (DataResource.dict_settings["game_on"] == true):
				print("instanced inventory")
				instance_scene(INVENTORY)
				last_key = KEY_I
			elif(last_key == KEY_I):
				print("released inventory")
				free_scene()
				last_key = null
		else:
			print("unknown")
	else:
		print("major scene")


func instance_scene(NEW):
	var curr_scene = NEW.instance()
	DataResource.current_scene.add_child(curr_scene)


func free_scene():
	DataResource.dict_settings["game_on"] = true
	var instanced_scene = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	if(instanced_scene):
		instanced_scene.queue_free()
