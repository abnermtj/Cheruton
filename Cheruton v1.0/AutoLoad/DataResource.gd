extends Node

# Adding data to the game dictionary:
#	DataResource.dict_x["feature"] = value

const FILE_PLAYER = "res://SaveData/player-data.json"
const FILE_SETTINGS = "res://SaveData/settings-data.json"

var current_scene = null

var audio
var is_mute
var game_on
var maj_scn

var health_curr
var health_max
var damage
var exp_curr
var exp_max
var level
var coins

var dict_player = {
#        "filename" : get_filename(),
#        "parent" : get_parent().get_path(),
#        "pos_x" : position.x, # Vector2 is not supported by JSON
#        "pos_y" : position.y,
#        "gender" : gender
#        "attack" : attack,
#        "defense" : defense,
		"health_curr" : health_curr,
		"health_max" : health_max,
#        "damage" : damage,
#        "regen" : regen,
		"exp_curr" : exp_curr,
		"exp_max" : exp_max,
		"level" : level,
		"coins" : coins,
#        "attack_bonus" : attack_bonus,
#        "defense_bonus" : defense_bonus,
#        "health_bonus" : health_bonus,
#        "is_alive" : is_alive,
#        "last_attack" : last_attack
}

var dict_settings = {
	"audio" : audio,
	"is_mute": is_mute,
	"game_on": game_on,
	"maj_scn": maj_scn
#       "brightness" : get_parent().get_path(),
#       "color_indibars" : position.x,
#       "mmenubg" : mmenubg
}

func save_player():
	save_data(FILE_PLAYER, dict_player)

func save_settings():
	save_data(FILE_SETTINGS, dict_settings)

func load_player():
	dict_player = load_data(FILE_PLAYER, dict_player)

func load_settings():
	dict_settings = load_data(FILE_SETTINGS, dict_settings)

func save_data(FILE, dictionary):
	var file = File.new()
	file.open(FILE, File.WRITE)
	file.store_string(to_json(dictionary))
	file.close()

func load_data(FILE, dict):
	var file = File.new()
	if file.file_exists(FILE):
		file.open(FILE, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			dict = data
			print("Loaded data!")
			return dict
		else:
			print("Corrupted data!")
	else:
		print("No saved data!")


func reset_player():
	dict_player["exp_curr"] = 0
	dict_player["exp_max"] = 60
	dict_player["health_curr"] = 50
	dict_player["health_max"] = 50
	dict_player["level"] = 1
	dict_player["coins"] = 10
	save_player()

func reset_settings():
	dict_settings["audio"] = -10
	dict_settings["is_mute"] = false
	dict_settings["game_on"] = false
	dict_settings["maj_scn"] = true
	save_settings()
