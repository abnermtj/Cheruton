extends Node2D

const WELCOME = "res://Display/Welcome/Welcome.tscn"

onready var levels = $Levels
onready var hud_elements = $HudLayer/Hud
onready var load_layer = $load_layer/load

var curr_screen
## warning-ignore:unused_class_variable
#onready var hud_chrystalpos = [ \
#	$hud_layer/hud/chrystals/green.position, \
#	$hud_layer/hud/chrystals/white.position, \
#	$hud_layer/hud/chrystals/red.position ]


func _ready():
	load_screen(WELCOME)
	#var _ret = gamestate.connect( "gamestate_changed", self, "_on_gamestate_change" )

# Loads the next scene 
func load_screen(scene, game_scene:= false, loading_screen:= false):
	if (!game_scene):
		curr_screen = scene

	print( "LOADING SCREEN: ", curr_screen)
	get_tree().paused = true
	if(loading_screen):
		load_layer.show()
	
	if(hud_elements.visible):
		hud_elements.hide()

	#$hud_layer/hud.hide()
	var children = levels.get_children()
	if (!children.empty()):
		children[0].queue_free()
		
	var new_level = load(scene).instance()
	levels.add_child(new_level)

	if(game_scene):
		hud_elements.show()
		
	if(loading_screen):
		load_layer.hide()
	
	
	#$fade_layer/fadeanim.play( "fade_in")
	get_tree().paused = false
	

#==================================
# Load GameState
#==================================
#func load_gamestate() -> void:
#
#	get_tree().paused = true
#	$fade_layer/fadeanim.play( "fade_out" )
#
#	$hud_layer/hud.hide()
#	var children = $Levels.get_children()
#	if not children.empty():
#		children[0].queue_free()
#
#	var new_level# = load( gamestate.state.current_lvl ).instance()
#	$Levels.add_child( new_level )
#	get_tree().paused = false
#	$hud_layer/hud/game_map.call_deferred( "_update_map" )
#	$hud_layer/hud.show()
	
	#$fade_layer/fadeanim.play( "fade_in" )








#func pause_game():
#	$hud_layer/hud/game_map.hide()
#
#	get_tree().paused = true
#
#	var m = $hud_layer/hud/game_map/Viewport/map
#	$hud_layer/hud/game_map/Viewport.remove_child( m )
#	$pause_layer/pause/map.add_child( m )
#
#	var partname = ""
#	if $hud_layer/hud/game_map.cur_part != null:
#		partname = $hud_layer/hud/game_map.cur_part.name
#	for c in m.get_children():
#		if c is MapPart and c.name == partname: c.flash = true
#	$pause_layer/pause.show()
#
#	$pause_layer/pause/pause_menu.activate()
#
#
#func _on_pause_menu_pause_finished( cont ):
#	$pause_layer/pause/pause_menu.deactivate()
#	yield( get_tree().create_timer( 0.25 ), "timeout" )
#
#	$pause_layer/pause.hide()
#	var m = $pause_layer/pause/map.get_child(0)
#	var partname = ""
#	if $hud_layer/hud/game_map.cur_part != null:
#		partname = $hud_layer/hud/game_map.cur_part.name
#	for c in m.get_children():
#		if c is MapPart and c.name == partname: c.flash = false
#	$pause_layer/pause/map.remove_child( m )
#	$hud_layer/hud/game_map/Viewport.add_child( m )
#
#	$hud_layer/hud/game_map.show()
#	get_tree().paused = false
#
#	if not cont:
#		load_screen( MENU_SCN )





#func _on_gamestate_change():
#	# update chrystals
#	if gamestate.state.green_chrystal:
#		$hud_layer/hud/chrystals/green/original.show()
#	else:
#		$hud_layer/hud/chrystals/green/original.hide()
#	if gamestate.state.white_chrystal:
#		$hud_layer/hud/chrystals/white/original.show()
#	else:
#		$hud_layer/hud/chrystals/white/original.hide()
#	if gamestate.state.red_chrystal:
#		$hud_layer/hud/chrystals/red/original.show()
#	else:
#		$hud_layer/hud/chrystals/red/original.hide()
#	# update energy
#	match gamestate.state.energy:
#		0:
#			$hud_layer/hud/energy/heart_1.hide()
#			$hud_layer/hud/energy/heart_2.hide()
#			$hud_layer/hud/energy/heart_3.hide()
#		1:
#			$hud_layer/hud/energy/heart_1.show()
#			$hud_layer/hud/energy/heart_2.hide()
#			$hud_layer/hud/energy/heart_3.hide()
#		2:
#			$hud_layer/hud/energy/heart_1.show()
#			$hud_layer/hud/energy/heart_2.show()
#			$hud_layer/hud/energy/heart_3.hide()
#		3:
#			$hud_layer/hud/energy/heart_1.show()
#			$hud_layer/hud/energy/heart_2.show()
#			$hud_layer/hud/energy/heart_3.show()
#
#
#func set_hud_particles( v ):
#	match v:
#		0:
#			$hud_layer/hud/chrystals/green/particles.emitting = true
#		1:
#			$hud_layer/hud/chrystals/white/particles.emitting = true
#		2:
#			$hud_layer/hud/chrystals/red/particles.emitting = true

#func show_bottom_msg( msg : String ):
#	$hud_layer/hud/special_messages/message/bottom_label.text = msg
#	$hud_layer/hud/special_messages/message/msganim.play( "show" )


# Preload music cause we have tons of memory...?
#var music = [ \
#	preload( "res://music/menu.ogg" ), \
#	preload( "res://music/main.ogg" ), \
#	preload( "res://music/mountain.ogg" ), \
#	preload( "res://music/main_without_tune.ogg" ) ]
#var music_cur = -1
#var music_nxt = -1
#var fade_in := 0.0
#var fade_out := 0.0
#var music_state := -1
#var match_position := false
#func set_music( no : int, _fade_out : float = 0.5, _fade_in : float = 0.5, _match_position : bool = false ):
#	if no == music_cur: return
#	self.music_nxt = no
#	self.fade_in = _fade_in
#	self.fade_out = _fade_out
#	self.match_position = _match_position
#	$music/vol_pitch_control.stop()
#	music_state = 0
#	music_fsm()

#func music_fsm():
#	match music_state:
#		0:
#			# fade out
#			music_state = 1
#			if fade_out > 0:
#				$music/vol_pitch_control.play( "fade_out", -1, 1.0 / fade_out )
#			else:
#				$music.volume_db = -60.0
#				call_deferred( "music_fsm" )
#		1:
#			# record position
#			var start_position = 0.0
#			if match_position:
#				start_position = $music.get_playback_position()
#			# load new music
#			music_state = 2
#			music_cur = music_nxt
#			$music.stream = music[music_cur]
#			$music.play( start_position )
#			# fade in
#			if fade_in > 0:
#				$music/vol_pitch_control.play( "fade_in", -1, 1.0 / fade_in )
#			else:
#				$music.volume_db = 0.0
#				call_deferred( "music_fsm" )
#		2:
#			# not much to do
#			music_state = -1
#
#func _on_vol_pitch_control_animation_finished( _anim_name ):
#	music_fsm()
#
#func slow_music( n : int ):
#	match n:
#		0:
#			# normal mode
#			$music/pitch_control.play( "normal" )
#		1:
#			# slow down
#			$music/pitch_control.play( "slow" )
#		2:
#			# return to normal
#			$music/pitch_control.play_backwards( "slow" )
#
#func level_restart_sfx():
#	$level_restart.play()
