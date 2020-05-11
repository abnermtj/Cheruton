extends Control

var active_tab
var count = 0

onready var active_tab_image = preload("res://Player/Inventory/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/inventory_bg.png")

func _ready():
	DataResource.dict_settings["game_on"] = false
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Coins/CoinsVal.text = str(DataResource.dict_player["coins"])

	# Hide initbar() to view inventory directly
	#$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/ExpBar.initbar()
	#$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/HealthBar.initbar()
	#change_active_tab($BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Weapons/Weapons)



func _on_Exit_pressed():
	free_the_inventory()

func free_the_inventory():
	DataResource.dict_settings["game_on"] = true
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()

func change_active_tab(new_tab):
	# Set current tab to default colour
	if(active_tab):
		active_tab.set_normal_texture(default_tab_image)
	# Set new active tab and its colour
	active_tab = new_tab
	active_tab.set_normal_texture(active_tab_image)

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


func _on_Weapons_pressed():
	change_active_tab($BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Weapons/Weapons)


func _on_Apparel_pressed():
	change_active_tab($BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Apparel/Apparel)


func _on_Aid_pressed():
	change_active_tab($BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Aid/Aid)


func _on_Misc_pressed():
	change_active_tab($BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Misc/Misc)


func _on_KeyItem_pressed():
	change_active_tab($BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/KeyItem/KeyItem)
