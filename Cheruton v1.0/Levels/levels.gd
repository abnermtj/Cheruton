# base class For all levels
extends Node2D
class_name Level

# commonly referenced nodes only

var bg_music_file 
var player
var camera

func _ready() -> void:
	DataResource.current_scene = self
	if(!DataResource.loaded):
		DataResource.load_data()


	SceneControl.get_node("masterGui").enabled = true

	call_deferred( "_set_camera" )
	call_deferred( "_set_player" )
	call_deferred("_set_player_objects")
	call_deferred("_set_level")
	set_music()

func _set_player() -> void:
	player = find_node( "player" )
	if player == null:
		print( "Level: player not found" )

func _set_camera() -> void:
	camera = find_node( "camera" )
	if camera == null:
		print( "Level: camera not found" )
	var pos_NW = find_node( "camera_limit_NW" )
	if pos_NW:
		camera.limit_left = pos_NW.position.x
		camera.limit_top = pos_NW.position.y

	var pos_SE = find_node( "camera_limit_SE" )
	if pos_SE:
		camera.limit_right = pos_SE.position.x
		camera.limit_bottom = pos_SE.position.y

func _set_player_objects() -> void:
	if not player: return

	if camera:
		player.connect("camera_command", camera, "_on_player_camera_command")

	var grapple_hook = find_node ("grappleHook")
	if grapple_hook == null:
		print( "Level: grappleHook not found" )
	else:
		grapple_hook.connect("hooked", player, "_on_Chain_hooked")
		player.connect("hook_command", grapple_hook, "_on_player_hook_command")

	var flying_sword = find_node("flyingSword")
	if flying_sword == null:
		print( "Level: flyingSword not found" )
	else:
		flying_sword.connect("sword_result", player, "on_sword_result")
		player.connect("flying_sword_command", flying_sword, "_on_flyingSword_command")

func _set_level():
	var death_zone = find_node("DeathZone")

	if not death_zone:
		print("death_zone not found")
	else:
		death_zone.connect("body_entered", self, "handle_death_zone")

# loads prev checkpoint
func _on_player_dead() -> void:
	pass

func set_music():
	pass

func handle_death_zone(body):
	pass
