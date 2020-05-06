extends Node


const PAUSE = preload("res://Display/Pause/Pause.tscn")
const INVENTORY = preload("res://Player/Inventory/Inventory.tscn")

func _input(ev): 
	if Input.is_key_pressed(KEY_P):
		#Prevents instancing during non-gameplay scenes
		if (DataResource.dict_settings["game_on"] == false):
			return
		var curr_scene = PAUSE.instance()
		DataResource.current_scene.add_child(curr_scene)
		curr_scene.popup()

	elif Input.is_key_pressed(KEY_I):
		if (DataResource.dict_settings["game_on"] == false):
			return
		var curr_scene = INVENTORY.instance()
		DataResource.current_scene.add_child(curr_scene)

