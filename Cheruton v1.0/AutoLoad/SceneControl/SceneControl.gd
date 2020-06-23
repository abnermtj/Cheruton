extends Node2D

const WELCOME = "res://Display/Welcome/Welcome.tscn"

onready var levels = $Levels
onready var hud_elements = $HudLayer/Hud
onready var load_layer = $LoadLayer/Load
onready var bg_music = $BgMusic

var curr_screen
var loot_dict = {} # Items pending transfer to inventory

enum item{TYPE = 0, NAME = 1, AMOUNT = 2}

## warning-ignore:unused_class_variable
#onready var hud_chrystalpos = [ \
#	$hud_layer/hud/chrystals/green.position, \
#	$hud_layer/hud/chrystals/white.position, \
#	$hud_layer/hud/chrystals/red.position ]


#func _ready():
#	load_screen(WELCOME)

	#var _ret = gamestate.connect( "gamestate_changed", self, "_on_gamestate_change" )

# Loads the next scene 
func load_screen(scene, game_scene:= false, loading_screen:= false):
	if (!game_scene):
		curr_screen = scene

	if(bg_music):
		bg_music.stop()

	print( "LOADING SCREEN: ", curr_screen)
	get_tree().paused = true
	if(loading_screen):
		load_layer.show()
	
	if(hud_elements.visible):
		hud_elements.hide()
		
	if(loading_screen):
		yield(get_tree().create_timer(0.2), "timeout")
	#
	#$hud_layer/hud.hide()
	var children = levels.get_children()
	if (!children.empty()):
		children[0].queue_free()
	
	if(loading_screen):
		yield(get_tree().create_timer(0.05), "timeout")
	
	var new_level = load(scene).instance()
	levels.add_child(new_level)
	
	if(loading_screen):
		yield(get_tree().create_timer(0.6), "timeout")
	
	if(game_scene):
		hud_elements.show()
		
	if(loading_screen):
		load_layer.hide()
	
	#bg_music.set_stream(levels.find_node("background_music", true, false)
	
	#$fade_layer/fadeanim.play( "fade_in")
	get_tree().paused = false




func determine_loot(map):
	var loot_count = determine_loot_count(map)
	loot_selector(map, loot_count)
	append_loot(loot_count)

# Determines the qty of tiems to be released
func determine_loot_count(map_name):
	var ItemMinCount = DataResource.dict_item_spawn[map_name].ItemMinCount
	var ItemMaxCount = DataResource.dict_item_spawn[map_name].ItemMaxCount

	randomize()
	var loot_count = randi()%((int(ItemMaxCount) - int(ItemMinCount))+ 1) + int(ItemMinCount)
	return loot_count

# Determines what items and their respective qty to be released
# Needs rework. Currently, the next loot item can only be obtained after the previous one is
func loot_selector(map_name, loot_count):
	for _i in range(loot_count):
		randomize()
		var index = 1
		var loot_chance = randi() % 100 + 1
		while(loot_chance > -1):
			# Item has been found - take note of its critical elements
			if(loot_chance <= DataResource.dict_item_spawn[map_name]["ItemChance"+ str(index)]):
				var loot = []
				loot.append(DataResource.dict_item_spawn[map_name]["ItemType"+ str(index)])
				loot.append(DataResource.dict_item_spawn[map_name]["ItemName"+ str(index)])
				randomize()
				#Randomize the qty of the item to be found
				loot.append(int(rand_range(float(DataResource.dict_item_spawn[map_name]["ItemMinQ" + str(index)]), float(DataResource.dict_item_spawn[map_name]["ItemMaxQ"+ str(index)]))))
				loot_dict[loot_dict.size() + 1] = loot
				break
			#Item not found, manipulate loot_chance val and compare against next index
			else:
				loot_chance -= DataResource.dict_item_spawn[map_name]["ItemChance" + str(index)]
				index += 1

# Transfers all loot present in loot_dict to dict_inventory
func append_loot(loot_count):
	var index = 1
	while loot_count:
		var item_type = loot_dict[index][item.TYPE]

		# Money
		if(loot_dict[index][0] == "Money"):
			DataFunctions.change_coins(int(loot_dict[index][item.AMOUNT]))

		# Non Money
		else:
			# Empty Tab
			if(DataResource.dict_inventory[item_type].size() == 0):
				var curr_size = DataResource.dict_inventory[item_type].size() + 1
				insert_data(index, curr_size)

			# Non-Empty Tab
			else:
				for i in range(1, DataResource.dict_inventory[item_type].size() + 1):
					# Item exists in inventory
					if(DataResource.dict_inventory[item_type]["Item" + str(i)].item_name == loot_dict[index][item.NAME]):
						DataResource.dict_inventory[item_type]["Item" + str(i)].item_qty += loot_dict[index][item.AMOUNT]
						break
					# Item not present
					var curr_size = DataResource.dict_inventory[item_type].size() + 1
					insert_data(index, curr_size)
		index += 1
		loot_count -= 1
	DataResource.save_rest()

# inserts item to inventory at insert_index
func insert_data(item_id, insert_index):
	var item_name = loot_dict[item_id][item.NAME]
	var stats =  {
				"item_name": loot_dict[item_id][1],
				"item_attack": DataResource.dict_item_masterlist[item_name].ItemAtk,
				"item_defense": DataResource.dict_item_masterlist[item_name].ItemDef,# stub - to update
				"item_statheal": DataResource.dict_item_masterlist[item_name].StatHeal,
				"item_healval": DataResource.dict_item_masterlist[item_name].HealVal,
				"item_value": DataResource.dict_item_masterlist[item_name].ItemValue,
				"item_details": DataResource.dict_item_masterlist[item_name].ItemDetails,
				"item_png": DataResource.dict_item_masterlist[item_name].ItemPNG,
				"item_qty": loot_dict[item_id][2],
		}
	DataResource.dict_inventory[loot_dict[item_id][item.TYPE]]["Item" + str(insert_index)] = stats


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
