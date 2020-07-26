extends Node2D

const MMENU = "res://Display/MainMenu/MainMenu.tscn"
enum item{TYPE = 0, NAME = 1, AMOUNT = 2}

onready var arrow = preload("res://Display/MouseDesign/arrow.png")
onready var beam = preload("res://Display/MouseDesign/beam.png")
onready var mmenu_music_file = preload("res://Music/Background/Time Trip.wav")


onready var levels = $Levels
onready var hud_elements = $HudLayer/Hud
onready var pop_up_gui = $popUpGui
onready var bg_music = $BgMusic
onready var load_layer = $LoadLayer/Load
onready var settings_layer = $SettingsLayer/Settings
onready var button_click = $ButtonClick
onready var scene_change = $SceneChange

var cur_story
var cur_dialog

var curr_scene
var loot_dict = {} # Items pending transfer to inventory
var enable_save := false

var cur_level

var music_curr
var music_next
var music_state := "idle"

signal init_statbar

func _ready():
	bg_music.volume_db = -60
	randomize()
	change_music(mmenu_music_file)
	init_music()
	#init_cursor()

##############
# INITIALIZE #
##############
func init_music():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), DataResource.dict_settings.is_mute)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), DataResource.dict_settings.audio_master)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), DataResource.dict_settings.audio_music)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), DataResource.dict_settings.audio_sfx)



func init_cursor():
	Input.set_custom_mouse_cursor(arrow)
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)


################
# SCENE CHANGE #
################

func change_music(new_music):
	bg_music.stream = new_music
	bg_music.play()


# Loads the next scene
func load_screen(scene, game_scene:= false):
	var new_music
	
	scene_change.play("scene_out")
	get_tree().paused = true

	var children = levels.get_children()
	if children:
		children[0].queue_free()

	var new_level = load(scene).instance()

	if(scene != MMENU):
		cur_level = new_level
		levels.add_child(new_level)
		new_music = levels.get_child(levels.get_child_count() - 1).bg_music_file
		change_story(levels.get_child(levels.get_child_count() - 1).story_file)
		if(new_music):
			new_music = load(new_music)
		change_music(new_music)

	else: # main menu
		var root = get_tree().get_root()
		root.add_child(new_level)
		change_music(mmenu_music_file)

	print("new_music", new_music)
	print("Loaded")
	get_tree().paused = false

func _on_SceneChange_animation_finished(anim_name):
	if(anim_name == "scene_out"):
		scene_change.play("scene_in")
	else:
		get_tree().paused = false

########
# LOOT #
########

func determine_loot(map):
	loot_selector(map)
	append_loot(map)


# Determines what items and their respective qty to be released
# Needs rework. Currently, the next loot item can only be obtained after the previous one is
func loot_selector(map_name):
	var index = 1
	var max_range = DataResource.dict_item_spawn[map_name]["ItemIndexes"]
	for _i in range(max_range):

		var loot_chance = randi() % 100 + 1

		# Item has been found - take note of its critical elements
		if(loot_chance <= DataResource.dict_item_spawn[map_name]["ItemChance"+ str(index)]):
			var loot = []
			loot.append(DataResource.dict_item_spawn[map_name]["ItemType"+ str(index)])
			loot.append(DataResource.dict_item_spawn[map_name]["ItemName"+ str(index)])
			#Randomize the qty of the item to be found
			loot.append(int(rand_range(float(DataResource.dict_item_spawn[map_name]["ItemMinQ" + str(index)]), float(DataResource.dict_item_spawn[map_name]["ItemMaxQ"+ str(index)]))))
			loot_dict[loot_dict.size() + 1] = loot

		index += 1

# Transfers all loot present in loot_dict to dict_inventory
func append_loot(map_name):
	var index = 1
	var loot_count = loot_dict.size()
	while loot_count != 0:
		var item_type = loot_dict[index][item.TYPE]

		# Money
		if(loot_dict[index][0] == "Money"):
			DataResource.change_coins(int(loot_dict[index][item.AMOUNT]))

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
	loot_dict.clear()
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


########
# INPUT #
########
func _input(_ev):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if Input.is_action_just_pressed("save_player"):
		if(enable_save):
			DataResource.save_player()

#########
# DIALOG #
#########
func change_story(story): # a collection of dialogs
	if not story: return

	cur_story = story
	pop_up_gui.get_node("popUps/dialog").load_story(cur_story)

func change_and_start_dialog(dialog : String):
	cur_dialog = dialog
	call_deferred("_change_and_start_dialog")

func _change_and_start_dialog():
	pop_up_gui.get_node("popUps").new_gui("dialog")
	pop_up_gui.get_node("popUps/dialog").start_dialog(cur_dialog)

func set_dialog_only_mode(val : bool):
	if val == true:
		pop_up_gui.dialog_only()
	else:
		pop_up_gui.end_dialog_only()






