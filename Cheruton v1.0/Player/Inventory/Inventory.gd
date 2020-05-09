extends Control

var count = 0


func _ready():
	DataResource.dict_settings["game_on"] = false
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Coins/CoinsVal.text = str(DataResource.dict_player["coins"])
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/ExpBar.initbar()
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/HealthBar.initbar()

func _on_Exit_pressed():
	free_the_inventory()

func free_the_inventory():
	DataResource.dict_settings["game_on"] = true
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()



#func _on_Test_pressed(): # creates a double click signal and activates tooltips
#	if(count == 0):
#		$CountDown.start()
#	count += 1
#	if (count == 2):
#		count = 0
#
#func tooltips(texture):
#	$Tooltips/CurrItem.set_texture(texture)
#
#func _on_CountDown_timeout():
#	count = 0
