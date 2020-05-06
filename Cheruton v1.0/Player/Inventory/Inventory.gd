extends Control

var count = 0

signal double_pressed

func _ready():
	DataResource.dict_settings["game_on"] = false
	self.connect("double_pressed", self, "equip")
	DataFunctions.connect("change_coins", self, "update_coins")
	$Coin/CoinValue.text = str(DataResource.dict_player["coins"])


#func _on_Button_pressed(): # creates a double click signal
#	count += 1
#	if (count == 2):
#		emit_signal("double_pressed")
#		count = 0

func equip():
	$Label.show()



func _on_Exit_pressed():
	free_the_inventory()

func free_the_inventory():
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()
	DataResource.dict_settings["game_on"] = true
