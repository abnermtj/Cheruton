extends Node

# Adding data to the game dictionary:
#	DataResource.dict_x["feature x"] = value
#   DataResource.dict_x.feature = value

const SETTINGS = "res://SaveData/settings-data.json"
const PLAYER = "res://SaveData/player-data.json"
const INVENTORY = "res://SaveData/inventory-data.json"
const LOOT = "res://SaveData/loot-data.json"

var current_scene = null

var dict_inventory
var dict_loot
var dict_player
var dict_settings

# Stores any unsaved data regarding player stats
var temp_dict_player

func load_data():
	dict_settings = load_dict(SETTINGS)
	dict_player = load_dict(PLAYER)
	dict_inventory = load_dict(INVENTORY)
	dict_loot = load_dict(LOOT)
	temp_dict_player = dict_player


func load_dict(FilePath):
	var DataFile = File.new()
	DataFile.open(FilePath, File.READ)
	var data = JSON.parse(DataFile.get_as_text())
	DataFile.close()
	print("Data Loaded!")
	return data.result


func save_player():
	dict_player = temp_dict_player
	save_data(PLAYER, dict_player)
	temp_dict_player = dict_player

func save_settings():
	save_data(SETTINGS, dict_settings)

func save_inventory():
	save_data(INVENTORY, dict_inventory)


func save_data(FILE, dictionary):
	var file = File.new()
	file.open(FILE, File.WRITE)
	file.store_string(to_json(dictionary))
	file.close()

func restore_last_save():
	temp_dict_player = dict_player


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
	save_settings()
