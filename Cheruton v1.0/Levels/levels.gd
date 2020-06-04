# base class For all levels
extends Node2D
class_name Level

func _ready() -> void:
	DataResource.current_scene = self
	DataResource.load_data()

	LevelguiMaster.enabled = true

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

# loads prev checkpoint
func _on_player_dead() -> void:
	pass

func set_music():
	pass
