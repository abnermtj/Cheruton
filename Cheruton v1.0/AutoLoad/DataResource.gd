extends Node

# Adding data to the game dictionary:
#	DataResource.dict_x["feature x"] = value
#   DataResource.dict_x.feature = value

const MAIN = "res://SaveData/player-data.json"

var current_scene = null

var dict_main = {}
var dict_inventory = {}
var dict_item_spawn = {}
var dict_player = {}
var dict_settings = {}
var dict_item_masterlist = {}

# Stores any unsaved data regarding player stats
var temp_dict_player = {}

func load_data():
	#Editable
	dict_main = load_dict(MAIN)
	dict_player = dict_main.player.main
	dict_settings = dict_main.settings.main
	dict_inventory = dict_main.inventory
	temp_dict_player = dict_player

	#Non-Editable
	dict_item_spawn = dict_main.item_spawn
	dict_item_masterlist = dict_main.item_masterlist



func load_dict(FilePath):
	var DataFile = File.new()
	DataFile.open(FilePath, File.READ)
	#if(!DataFile.file_exists(FilePath)):
		#save_data(FilePath, dict_main)
		#reset_all()
	#var err = DataFile.open_encrypted_with_pass(FilePath, File.READ, "mypass")
	var data = JSON.parse(DataFile.get_as_text())
	DataFile.close()
	print("Data Loaded!")
	return data.result


func save_player():
	dict_player = temp_dict_player
	save_data(MAIN, dict_main)

func save_rest():
	save_data(MAIN, dict_main)


func save_data(FILE, dictionary):
	var file = File.new()
	file.open(FILE, File.WRITE)
	#file.open_encrypted_with_pass(FILE, File.WRITE, "mypass")
	file.store_string(to_json(dictionary))
	file.close()


func restore_last_save():
	temp_dict_player = dict_player

func reset_all():
	reset_player()

func reset_player():
	dict_player.exp_curr = 0
	dict_player.exp_max = 60
	dict_player.health_curr = 50
	dict_player.health_max = 50
	dict_player.level = 1
	dict_player.coins = 10
	save_player()

func reset_settings():
	dict_settings.audio = -10
	dict_settings.is_mute = false
	dict_settings.game_on = false
	dict_settings.maj_scn = true
	save_rest()
