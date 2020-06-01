extends Node


onready var PAUSE = preload("res://Display/Pause/Pause.tscn")
onready var INVENTORY = preload("res://Player/Inventory/Inventory_new.tscn")#stub

var last_key

#fix key closure to close only with assigned key! - find better check than getchild
func _input(_ev):
	print("MajScn:", DataResource.dict_settings.maj_scn)
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if(DataResource.dict_main && DataResource.dict_settings.maj_scn == false):
		print("toodles")
		if Input.is_action_just_pressed("escape"):
			instance_scene("escape", PAUSE)
			

		elif Input.is_action_just_pressed("inventory"):
			print("heerrree")
			instance_scene("inventory", INVENTORY)

func instance_scene(key, SCENE):
	yield(get_tree().create_timer(0.06), "timeout")
	if (DataResource.dict_settings.game_on):
		var curr_scene = SCENE.instance()
		DataResource.current_scene.add_child(curr_scene)
		last_key = key
	elif(last_key == key):
		free_scene()
		last_key = null


func free_scene():
	DataResource.dict_settings.game_on = true
	var instanced_scene = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	if(instanced_scene):
		instanced_scene.queue_free()
