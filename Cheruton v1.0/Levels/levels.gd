# base class For all levels
extends Node2D
class_name Level

var bg_music_file
var story_file
var player
var camera

# manages position of player on enter or map
var enter_point : int
var player_spawn_pos : Vector2
var entrace_to_pos_dict = {}

var wait_dialog_complete = false

var cutscene_number = 0
var cutscene_index = 0

##SETUP#####################################################################
func _ready() -> void:
	if(!DataResource.loaded):
		DataResource.load_data()

	SceneControl.get_node("popUpGui").enabled = true

	_set_player()
	_set_camera()
	_set_player_objects()
	_set_level()
	_set_level_player_references()
	call_deferred("enter_level")

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
	if grapple_hook:
		grapple_hook.connect("hooked", player, "_on_Chain_hooked")
		player.connect("hook_command", grapple_hook, "_on_player_hook_command")
	else:
		print("Level: grappleHook not found")

	var flying_sword = find_node("flyingSword")
	if flying_sword:
		flying_sword.connect("sword_result", player, "on_sword_result")
		player.connect("flying_sword_command", flying_sword, "_on_flyingSword_command")
	else:
		print("Level: flyingSword not found")

func _set_level():
	var death_zone = find_node("DeathZone")

	if death_zone:
		death_zone.connect("body_entered", self, "handle_death_zone")
	else:
		print("death_zone not found")

func _set_level_player_references():
	var player_refs = get_tree().get_nodes_in_group("needs_player_ref")
	var level_refs = get_tree().get_nodes_in_group("needs_level_ref")

	if player:
		for node in player_refs:
			node.player = player

	for node in level_refs:
		node.level = self

func enter_level():
	player.global_position = player_spawn_pos
################################################################################


# loads prev checkpoint
func on_player_dead():
	player.global_position = player_spawn_pos
	DataResource.change_health(9999)

func handle_death_zone(body):
	pass
func next_cutscene():
	pass

func start_cutscene_mode():
	player.set_input_enabled(false)
	SceneControl.set_dialog_only_mode(true)

func end_cutscene_mode():
	player.set_input_enabled(true)
	SceneControl.set_dialog_only_mode(false)

func shake_camera(dur : float, freq : float , amp : float , dir : Vector2):
	camera.shake(dur, freq, amp, dir)
