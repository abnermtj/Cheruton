extends Node

# Fix these locations as the save file location

const FILE_NAME = "res://game-data.json"
const FILE_NAME2 = "res://settings-data.json"
var audio
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
#        "experience" : experience,
#        "tnl" : tnl,
#        "level" : level,
#        "attack_bonus" : attack_bonus,
#        "defense_bonus" : defense_bonus,
#        "health_bonus" : health_bonus,
#        "is_alive" : is_alive,
#        "last_attack" : last_attack
}

var dict_settings = {
		"audio" : audio
#        "brightness" : get_parent().get_path(),
#        "color_indibars" : position.x, 
#        "mmenubg" : mmenubg
}



# Add data to the game dictionary - Guide
#		dict_x["player"] = player

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
