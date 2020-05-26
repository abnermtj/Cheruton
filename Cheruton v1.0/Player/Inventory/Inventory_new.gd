extends Control

var active_tab

signal tab_changed(next_tab)

onready var active_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg.png")

onready var weapons_list = DataResource.dict_inventory.get("Weapons")
onready var apparel_list = DataResource.dict_inventory.get("Apparel")
onready var consum_list = DataResource.dict_inventory.get("Consum")
onready var misc_list = DataResource.dict_inventory.get("Misc")
onready var key_items_list = DataResource.dict_inventory.get("Key Items")


onready var tabs = $Border/Bg/Contents/Tabs
onready var items = $Border/Bg/Contents/Items
onready var equipped_coins = $Border/Bg/Contents/EquippedCoins

func _ready():
	DataResource.dict_settings.game_on = false
	connect_tabs()
	load_data()
	emit_signal("tab_changed", "Weapons")
	
	equipped_coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])
	

func _on_Exit_pressed():
	free_the_inventory()

func free_the_inventory():
	DataResource.dict_settings.game_on = true
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()

# Links the buttons when pressed into the function to change active tab
func connect_tabs():
	connect("tab_changed", self, "change_tab_state")
	tabs.get_node("Weapons/Weapons").connect("pressed", self,  "tab_pressed", ["Weapons"])
	tabs.get_node("Apparel/Apparel").connect("pressed", self,  "tab_pressed", ["Apparel"])
	tabs.get_node("Consum/Consum").connect("pressed", self,  "tab_pressed", ["Consum"])
	tabs.get_node("Misc/Misc").connect("pressed", self,  "tab_pressed", ["Misc"])
	tabs.get_node("KeyItems/KeyItems").connect("pressed", self,  "tab_pressed", ["KeyItems"])
	
func tab_pressed(next_tab):
	if(active_tab.name != next_tab):
		emit_signal("tab_changed", next_tab)
		
func change_tab_state(next_tab):
	match next_tab:
		"Weapons":   change_active_tab(tabs.get_node("Weapons/Weapons"))
		"Apparel":   change_active_tab(tabs.get_node("Apparel/Apparel"))
		"Consum":    change_active_tab(tabs.get_node("Consum/Consum"))
		"Misc":      change_active_tab(tabs.get_node("Misc/Misc"))
		"KeyItems": change_active_tab(tabs.get_node("KeyItems/KeyItems"))

	if(next_tab):
		print("Current Tab: ")
		print(next_tab)

func change_active_tab(new_tab):
	# Set current tab to default colour and hide its items
	if(active_tab):
		active_tab.set_normal_texture(default_tab_image)
		items.get_node(active_tab.name).hide()
	
	# Set new active tab and its colour and show its items
	active_tab = new_tab
	active_tab.set_normal_texture(active_tab_image)
	items.get_node(active_tab.name).show()
	print("OK")

func load_data():
	#Find subnodes of each tab
	var weapons_scroll = items.get_node("Weapons/Column")
	var apparel_scroll = items.get_node("Apparel/Column")
	var consum_scroll = items.get_node("Consum/Column")
	var misc_scroll = items.get_node("Misc/Column")
	var key_items_scroll = items.get_node("KeyItems/Column")

	#Generate list of items based on tab
	generate_list(weapons_scroll, weapons_list, 100)
	generate_list(apparel_scroll, apparel_list, 200)
	generate_list(consum_scroll, consum_list, 300)
	generate_list(misc_scroll, misc_list, 400)
	generate_list(key_items_scroll, key_items_list, 500)

func generate_list(scroll_tab, list_tab, tab_index):
	var index = 1
	var row_index = 0
	for _i in range(0, list_tab.size()):
		# New Row
		if(index / 10 != row_index && index % 10 != 0): 
			row_index += 1
			var new_row = HBoxContainer.new()
			scroll_tab.add_child(new_row)
			scroll_tab.get_child(get_node(scroll_tab).get_child_count() - 1).name = "Row" + str(row_index)
		
		var row = scroll_tab.get_node("Row" + str(row_index))
		
		# New Item
		var instance_loc = load("res://Player/Inventory/101.tscn")
		var instanced = instance_loc.instance()
		row.add_child(instanced)
		row.get_child(row.get_child_count() - 1).name = str(tab_index + index)

		#add data

		index += 1
	# Hide data
	scroll_tab.get_parent().hide()
