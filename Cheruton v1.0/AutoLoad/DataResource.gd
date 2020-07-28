extends Node

const MAIN = "user://player-data.json"
const MASTERLIST = "res://Data/item-masterlist.json"

var current_scene = null

# Main Dict
var dict_main = {}
var dict_inventory = {}
var dict_player = {}
var dict_settings = {}
var dict_input_map = {}

# Masterlist Dict
var dict_masterlist = {}
var dict_item_masterlist = {}
var dict_item_spawn = {}
var dict_item_shop = {}
# Stores any unsaved data regarding player stats
var temp_dict_player = {}
var loaded:= false

signal update_exp(new_exp, new_exp_max, new_level)
signal change_health(new_health)

signal change_audio_master
signal change_audio_music
signal change_audio_sfx

signal dialog_over

func _ready():
	load_data()

func load_data():
	#Editable
	loaded = true
	dict_main = load_dict(MAIN, "ginger")
	dict_masterlist = load_dict(MASTERLIST)
	dict_player = dict_main.player.main
	dict_settings = dict_main.settings.main
	dict_input_map = dict_main.input_map
	dict_inventory = dict_main.inventory
	temp_dict_player = dict_player
	dict_item_shop = dict_masterlist.item_shop[temp_dict_player.stage]

	#Non-Editable
	dict_item_spawn = dict_masterlist.item_spawn
	dict_item_masterlist = dict_masterlist.item_masterlist

	# Update Inputmap
	update_input_map()


func load_dict(FilePath, password:= ""):
	var DataFile = File.new()
	if(FilePath == MAIN && !DataFile.file_exists(FilePath)): # create new save
		save_data(FilePath, dict_main)
		reset_all()
	if(password != ""):
		DataFile.open_encrypted_with_pass(FilePath, File.READ, password)
	else:
		DataFile.open(FilePath, File.READ)
	var data = JSON.parse(DataFile.get_as_text())
	DataFile.close()
	#print("Data Loaded!")
	return data.result

func save_player():
	dict_player = temp_dict_player
	save_data(MAIN, dict_main)

func save_rest():
	save_data(MAIN, dict_main)


func save_data(FILE, dictionary):
	var file = File.new()
	#file.open(FILE, File.WRITE)
	var _err_save = file.open_encrypted_with_pass(FILE, File.WRITE,"ginger")

	file.store_string(to_json(dictionary))
	file.close()

func restore_last_save():
	temp_dict_player = dict_player

func update_input_map():
	var keys = dict_input_map.keys()
	var keys_size = keys.size()
	for i in keys_size:
		var action = keys[i]
		var event = dict_input_map[action]

		var existing_event = InputMap.get_action_list(action)[0].as_text()

		if(existing_event != event):
			modify_event(action, event)

func modify_event(action, event):
	var new_input = InputEventKey.new()
	var scancode = OS.find_scancode_from_string(event) 
	new_input.set_scancode(scancode)
	InputMap.action_erase_event(action, InputMap.get_action_list(action)[0])
	InputMap.action_add_event(action, new_input)

func reset_all():
	dict_main = {"player": {"main": {}}, "settings": {"main": {}}, "inventory": {}, "input_map": {} }

	dict_main.player.main = dict_player
	dict_main.settings.main = dict_settings
	dict_main.inventory = dict_inventory
	dict_main.input_map = dict_input_map
	reset_player()
	reset_settings()
	reset_inventory()
	reset_input_map()


func reset_player():
	dict_player.exp_curr = 0
	dict_player.exp_max = 60
	dict_player.health_curr = 50
	dict_player.health_max = 50
	dict_player.level = 1
	dict_player.coins = 999999
	dict_player.attack = 15
	dict_player.defense = 15
	dict_player.Weapons_item = null
	dict_player.Apparel_item = null
	dict_player.stage = "stage1"
	dict_player.completed_cutscenes = {"grasslands0_0" : false}
	save_player()

func reset_settings():
	dict_settings.audio_master = -6
	dict_settings.audio_music = -6
	dict_settings.audio_sfx = -6
	dict_settings.is_mute = false
	save_rest()

func reset_inventory():
	dict_inventory.Weapons =  {}
	dict_inventory.Apparel = {}
	dict_inventory.Consum = {}
	dict_inventory.Misc = {}
	dict_inventory["Key Items"] = {}
	save_rest()

func reset_input_map():
	var action_map = InputMap.get_actions()
	var action_size = action_map.size()
	for i in action_size:
		var action = action_map[i]
		if(action != "ui_select" && action != "ui_focus_prev"):
			var event = InputMap.get_action_list(action)[0].as_text()
			dict_input_map[action] = event
	save_rest()



func add_exp(var exp_gain):
	temp_dict_player.exp_curr += exp_gain

	# Next Level Reached
	if(temp_dict_player.exp_curr >= temp_dict_player.exp_max):
		increase_player_stats()

	emit_signal("update_exp", temp_dict_player.exp_curr, temp_dict_player.exp_max, temp_dict_player.level)

func increase_player_stats():
		temp_dict_player.level += 1
		temp_dict_player.exp_curr -= temp_dict_player.exp_max
		temp_dict_player.exp_max *= 1.5
		increase_specific("Weapons")
		increase_specific("Apparel")

func increase_specific(type):
	var equipped_item
	var equipped_item_val
	match type:
		"Weapons":
			equipped_item = temp_dict_player.Weapons_item
		"Apparel":
			equipped_item = temp_dict_player.Apparel_item
	if(!equipped_item):
		equipped_item_val = 0
	else:
		var element_index = str(int(equipped_item%100))
		match type:
			"Weapons":
				equipped_item_val = DataResource.dict_inventory.Weapons["Item" + element_index].item_attack
				temp_dict_player.attack = equipped_item_val + 1.2 * (temp_dict_player.attack - equipped_item_val)

			"Apparel":
				equipped_item_val = DataResource.dict_inventory.Apparel["Item" + element_index].item_defense
				temp_dict_player.defense = equipped_item_val + 1.2 * (temp_dict_player.defense - equipped_item_val)

func change_health(var health_change):
	temp_dict_player.health_curr = clamp(temp_dict_player.health_curr + health_change, 0, temp_dict_player.health_max)
	emit_signal("change_health", temp_dict_player.health_curr)

func change_coins(coins_change):
	temp_dict_player.coins += coins_change

func change_audio_master(var audio_change):
	dict_settings.audio_master = clamp(dict_settings.audio_master + audio_change, -68, 0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), DataResource.dict_settings.audio_master)
	emit_signal("change_audio_master")

func change_audio_music(var audio_change):
	dict_settings.audio_music = clamp(dict_settings.audio_music + audio_change, -68, 0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), DataResource.dict_settings.audio_music)
	emit_signal("change_audio_music")

func change_audio_sfx(var audio_change):
	dict_settings.audio_sfx = clamp(dict_settings.audio_sfx + audio_change, -68, 0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), DataResource.dict_settings.audio_sfx)
	emit_signal("change_audio_sfx")




