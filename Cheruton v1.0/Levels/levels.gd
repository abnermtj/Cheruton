# base class For all levels
extends Node2D
class_name Level

onready var pause = preload("res://Display/Pause/Pause.tscn")
onready var inventory = preload("res://Player/Inventory/Inventory_new.tscn")
onready var gui = $gui
var instanced_packed_scenes_stack = []

func _ready() -> void:
	DataResource.current_scene = self
	DataResource.dict_settings.game_on = true
	DataResource.load_data()
	call_deferred( "_set_player" )
	call_deferred( "_set_camera" )
	set_music()

func _set_player() -> void:
	var player = find_node( "player" )
	if player == null:
		print( "Level: player not found" )
		return

func _set_camera() -> void:
	var camera = find_node( "camera" )
	if camera == null:
		print( "Level: camera not found" )
		return
	var pos_NW = find_node( "camera_limit_NW" )
	if pos_NW:
		camera.limit_left = pos_NW.position.x
		camera.limit_top = pos_NW.position.y
	var pos_SE = find_node( "camera_limit_SE" )
	if pos_SE:
		camera.limit_right = pos_SE.position.x
		camera.limit_bottom = pos_SE.position.y

func _input(event):
	if Input.is_action_just_pressed("escape"):
		print(instanced_packed_scenes_stack)
		if instanced_packed_scenes_stack:
			release_gui_scene()
		else:
			instance_gui_scene(pause)
			instanced_packed_scenes_stack.append("pause")
	elif Input.is_action_just_pressed("inventory"):
		if instanced_packed_scenes_stack and instanced_packed_scenes_stack.back() == "inventory":
			release_gui_scene()
		elif instanced_packed_scenes_stack.empty():
			instance_gui_scene(inventory)
			instanced_packed_scenes_stack.append("inventory")

func instance_gui_scene(packed_scene):
	var instance = packed_scene.instance()
	gui.add_child(instance)

func release_gui_scene():
	instanced_packed_scenes_stack.pop_back()
	DataResource.dict_settings.game_on = true
	var instanced_scene = gui.get_child(gui.get_child_count() - 1)
	instanced_scene.queue_free() # use remove child to not completely unload invenotry

# loads prev checkpoint
func _on_player_dead() -> void:
	pass

func set_music():
	pass



