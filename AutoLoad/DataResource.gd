extends Node

# Fix these locations as the save file location
# Adding data to the game dictionary:
#	DataResource.dict_x["feature"] = value

const FILE_NAME = "res://SaveData/player-data.json"
const FILE_NAME2 = "res://SaveData/settings-data.json"
var audio
var exp_curr = 0
var exp_max = 0
var level = 0
var dict_player = {
#        "filename" : get_filename(),
#        "parent" : get_parent().get_path(),
#        "pos_x" : position.x, # Vector2 is not supported by JSON
#        "pos_y" : position.y,
#        "gender" : gender
#        "attack" : attack,
#        "defense" : defense,
#        "current_health" : current_health,
#        "max_health" : max_health,
#        "damage" : damage,
#        "regen" : regen,
		"exp_curr" : exp_curr,
		"exp_max" : exp_max,
		"level" : level,
#        "attack_bonus" : attack_bonus,
#        "defense_bonus" : defense_bonus,
#        "health_bonus" : health_bonus,
#        "is_alive" : is_alive,
#        "last_attack" : last_attack
}

var dict_settings = {
	"audio" : audio
#       "brightness" : get_parent().get_path(),
#       "color_indibars" : position.x, 
#       "mmenubg" : mmenubg
}

func save_player(): 
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(dict_player))
	file.close()

func save_settings(): 	
	var file = File.new()
	file.open(FILE_NAME2, File.WRITE)
	file.store_string(to_json(dict_settings))
	file.close()
	
func load_player():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			dict_player = data
		else:
			print("Corrupted data for player!")
	else:
		print("No saved data for player!")	
		
func load_settings():		
	var file = File.new()
	if file.file_exists(FILE_NAME2):
		file.open(FILE_NAME2, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			dict_settings = data
		else:
			print("Corrupted data for settings!")
	else:
		print("No saved data for settings!")

func reset_player():		
	dict_player["exp_curr"] = 0
	dict_player["exp_max"] = 60
	dict_player["level"] = 0
	save_player()

func reset_settings():	
	dict_settings["audio"] = -10
	save_settings()
	
