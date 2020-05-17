extends Node2D
class_name Level

# base class For all levels
var can_pause = true

func _ready() -> void:
	call_deferred( "_set_player" )
	call_deferred( "_set_camera" )
	set_music()

func _set_player() -> void:
	var player = find_node( "player" )
	if player == null:
		print( "Level: player not found" )
		return
	#player.global_position = startpos.global_position  #IMPT DO NOT DELETE
	#player.dir_nxt = gamestate.state.current_dir
	#player.connect( "player_dead", self, "_on_player_dead" )


func _set_camera() -> void:
	var camera = find_node( "camera" )
	if camera == null:
		print( "Level: camera not found" )
		return
	var pos_NW = find_node( "camera_limit_NW" )
	if pos_NW != null:
		camera.limit_left = pos_NW.position.x
		camera.limit_top = pos_NW.position.y
	var pos_SE = find_node( "camera_limit_SE" )
	if pos_SE != null:
		camera.limit_right = pos_SE.position.x
		camera.limit_bottom = pos_SE.position.y

func _process(delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

# loads prev checkpoint
func _on_player_dead() -> void:
	pass


func set_music():
	pass



