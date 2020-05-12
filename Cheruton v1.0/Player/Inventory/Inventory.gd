extends Control

var active_tab
var count = 0
var active_tab_items

onready var active_tab_image = preload("res://Player/Inventory/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/inventory_bg.png")

func _ready():
	DataResource.dict_settings.game_on = false
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Coins/CoinsVal.text = str(DataResource.temp_dict_player["coins"])
	load_data()
	
	# Weapons-Default
	_on_Weapons_pressed()

	# Hide initbar() to view inventory directly
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/ExpBar.initbar()
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/HealthBar.initbar()

func load_data():
	# Get data according to relevant sections
	pass

func item_inspector_default():
	#show stats of current item - only for weapon/apparel
	#show description of current item - rest
	pass

func item_inspector_new():
	#show description of item hovered upon
	pass

func change_active_tab(new_tab, items_list):
	# Set current tab to default colour and hide its items
	if(active_tab):
		active_tab.set_normal_texture(default_tab_image)
		active_tab_items.hide()

	# Set new active tab and its colour and show its items
	active_tab = new_tab
	active_tab_items = items_list
	active_tab.set_normal_texture(active_tab_image)
	active_tab_items.show()



func _on_Weapons_pressed():
	var tab = $BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Weapons/Weapons
	var list = $BorderBackground/InnerBackground/VBoxContainer/MElements/Weapons
	change_active_tab(tab, list)

func _on_Apparel_pressed():
	var tab = $BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Apparel/Apparel
	var list = $BorderBackground/InnerBackground/VBoxContainer/MElements/Apparel
	change_active_tab(tab, list)

func _on_Consum_pressed():
	var tab = $BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Consum/Consum
	var list = $BorderBackground/InnerBackground/VBoxContainer/MElements/Consum
	change_active_tab(tab, list)

func _on_Misc_pressed():
	var tab = $BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Misc/Misc
	var list = $BorderBackground/InnerBackground/VBoxContainer/MElements/Misc
	change_active_tab(tab, list)

func _on_KeyItems_pressed():
	var tab = $BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/KeyItems/KeyItems
	var list = $BorderBackground/InnerBackground/VBoxContainer/MElements/KeyItems
	change_active_tab(tab, list)


func _on_Exit_pressed():
	free_the_inventory()

func free_the_inventory():
	DataResource.dict_settings.game_on = true
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
