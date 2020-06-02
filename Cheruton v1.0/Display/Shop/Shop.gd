extends Control

var active_tab
var item_state = "HOVER"
var mouse_count = 0
var mouse_node
var shop_setting = "Buy"

signal tab_changed(next_tab)

onready var active_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg.png")
onready var index_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var index_equipped_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_equip.png")

onready var weapons_list = DataResource.dict_inventory.get("Weapons")
onready var apparel_list = DataResource.dict_inventory.get("Apparel")
onready var consum_list = DataResource.dict_inventory.get("Consum")
onready var misc_list = DataResource.dict_inventory.get("Misc")
onready var key_items_list = DataResource.dict_inventory.get("Key Items")


onready var contents = $Border/Bg/Main/Rest/Contents
onready var tabs = $Border/Bg/Main/Rest/Contents/Tabs
onready var items_sell = $Border/Bg/Main/Rest/Contents/ItemsSell
onready var items_buy = $Border/Bg/Main/Rest/Contents/ItemsBuy
onready var equipped_coins = $Border/Bg/Main/Rest/Contents/EquippedCoins

func _ready():
	DataResource.dict_settings.game_on = false
	connect_tabs()
	load_data()
	emit_signal("tab_changed", "Weapons")

	equipped_coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])
	

func _on_Exit_pressed():
	free_the_shop()


func display_equipped(name):
	var main = get_node("Border/Bg/Contents/Items")
	var type = get_node("Border/Bg/Contents/EquippedCoins/" + name)
	var node = main.find_node(str(DataResource.temp_dict_player[name + "_item"]), true, false)
	type.get_node("Background/ItemBg/ItemBtn").set_normal_texture(node.get_node("Background/ItemBg/ItemBtn").get_normal_texture())
	node.get_node("Background/ItemBg").texture = index_equipped_bg
	type.show()
		
func free_the_shop():
	DataResource.dict_settings.game_on = true
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	DataResource.save_rest()
	yield(get_tree().create_timer(0.2), "timeout")
	scene_to_free.queue_free()

# Links the buttons when pressed into the function to change active tab
func connect_tabs():
	connect("tab_changed", self, "change_tab_state")
	tabs.get_node("Weapons/Weapons").connect("pressed", self,  "tab_pressed", ["Weapons"])
	tabs.get_node("Apparel/Apparel").connect("pressed", self,  "tab_pressed", ["Apparel"])
	tabs.get_node("Consum/Consum").connect("pressed", self,  "tab_pressed", ["Consum"])
	tabs.get_node("Misc/Misc").connect("pressed", self,  "tab_pressed", ["Misc"])

	
func tab_pressed(next_tab):
	if(active_tab.name != next_tab):
		emit_signal("tab_changed", next_tab)
		
func change_tab_state(next_tab):
	match next_tab:
		"Weapons":   change_active_tab(tabs.get_node("Weapons/Weapons"))
		"Apparel":   change_active_tab(tabs.get_node("Apparel/Apparel"))
		"Consum":    change_active_tab(tabs.get_node("Consum/Consum"))
		"Misc":      change_active_tab(tabs.get_node("Misc/Misc"))

	if(next_tab):
		print("Current Tab: ")
		print(next_tab)

func change_active_tab(new_tab):
	# Set current tab to default colour and hide its items
	if(mouse_node):
		var temp = mouse_node
		revert_item_state()
		_on_mouse_exited(temp)
		
	if(active_tab):
		active_tab.set_normal_texture(default_tab_image)
		contents.get_node("Item" + shop_setting + "/" + active_tab.name).hide()
	
	# Set new active tab and its colour and show its items
	active_tab = new_tab
	active_tab.set_normal_texture(active_tab_image)
	contents.get_node("Item" + shop_setting + "/" + active_tab.name).hide()

func load_data():
	#Find subnodes of each tab
	var weapons_sell = items_sell.get_node("Weapons/Column")
	var apparel_sell = items_sell.get_node("Apparel/Column")
	var consum_sell = items_sell.get_node("Consum/Column")
	var misc_sell = items_sell.get_node("Misc/Column")

	#Generate list of items based on tab
	generate_list(weapons_sell, weapons_list, 100)
	generate_list(apparel_sell, apparel_list, 200)
	generate_list(consum_sell, consum_list, 300)
	generate_list(misc_sell, misc_list, 400)

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

		#Add properties
		var item = row.get_node(str(tab_index + index))
		item.get_node("Background/ItemBg/ItemBtn/Qty").text = str(list_tab["Item" + str(index)].item_qty)
		var item_pict
		if(list_tab["Item" + str(index)].item_png):
			item_pict  = load(list_tab["Item" + str(index)].item_png)
		item.get_node("Background/ItemBg/ItemBtn").set_normal_texture(item_pict)
		index += 1
		
		enable_mouse(item)
	# Hide data
	scroll_tab.get_parent().hide()
	
# Enable mouse functions of the item index
func enable_mouse(new_node):
		new_node.get_node("Background/ItemBg/ItemBtn").connect("pressed", self, "_on_pressed", [new_node])
		new_node.connect("mouse_entered", self, "_on_mouse_entered", [new_node])
		new_node.connect("mouse_exited", self, "_on_mouse_exited", [new_node])

		# For the TextureButton
		new_node.get_node("Background/ItemBg/ItemBtn").connect("mouse_entered", self, "_on_mouse_entered", [new_node])
		new_node.get_node("Background/ItemBg/ItemBtn").connect("mouse_exited", self, "_on_mouse_exited", [new_node])

func _on_mouse_entered(node):
	if(item_state == "HOVER"):
		print(node.name)
		node.get_node("Background/ItemBg").texture = index_bg


# Mouse leaves label section of the element
func _on_mouse_exited(node):
	if(item_state == "HOVER"):
		if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
			if(str(DataResource.temp_dict_player[active_tab.name + "_item"]) == node.name):
				node.get_node("Background/ItemBg").texture = index_equipped_bg
				return
		node.get_node("Background/ItemBg").texture = null


# When the icon of a item is pressed
func _on_pressed(node):
	if(mouse_count == 0):
		$Timer.start()
	mouse_count += 1
	mouse_node = node
	if (mouse_count == 2):
		print("Double Clicked!")
		mouse_count = 0


# Check if the doubleclick has happened
func _on_Timer_timeout():
	if(mouse_count == 1):
		print("Single Clicked!")
		revert_item_state()
		mouse_count = 0

func revert_item_state():

	if(item_state == "HOVER"):
		item_state = "FIXED"
		mouse_node.get_node("Background/ItemBg").texture = index_bg
		get_node("Border/Bg/Contents/EquippedCoins/Button").show()
	else:
		item_state = "HOVER"
		get_node("Border/Bg/Contents/EquippedCoins/Button").hide()
		mouse_node = null

func use_item():
	var element_index = str(int(mouse_node.name)%100)
	var item_used = false
	if (DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_statheal == "EXP"):
		DataFunctions.add_exp(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_healval)
		item_used = true
	elif(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_statheal == "HP" && DataResource.dict_player.health_curr != DataResource.dict_player.health_max):
		DataFunctions.change_health(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_healval)
		item_used = true

	if(item_used):
		delete_item()

# Reduces qty of item by 1
func delete_item():

	var element_index = str(int(mouse_node.name)%100)
	DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty -= 1
		#delete index
	if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
		if(DataResource.temp_dict_player[active_tab.name + "_item"] == mouse_node.name):
			DataResource.temp_dict_player[active_tab.name + "_item"] = null
			get_node("Border/Bg/Contents/EquippedCoins/" + active_tab.name).hide()
	if (DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty != 0):
		mouse_node.get_node("Background/ItemBg/ItemBtn/Qty").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty)
	else:

		# Item Stock is empty:
		#	Shift down all inventory entries by 1
		#	Delete the last empty index
		#	If the Row is empty (except Row0), delete it
		
		var main = get_node("Border/Bg/Contents/Items/" + active_tab.name)
		
		element_index = int(element_index)
		for _i in range(element_index, DataResource.dict_inventory[active_tab.name].size()):
			DataResource.dict_inventory[active_tab.name]["Item" + str(element_index)] = DataResource.dict_inventory[active_tab.name]["Item" + str(element_index + 1)]
			element_index += 1
			
		DataResource.dict_inventory[active_tab.name].erase("Item" + str(element_index))
		var deletion = str(int(mouse_node.name)/100 * 100 + element_index)  
		revert_item_state()
		main.find_node(deletion, true, false).queue_free()
		if(element_index/10 != 0 && element_index  %10 != 0  && main.has_node("Column/Row" + str(element_index/10))):
			main.find_node("Row" + str(element_index/10), true, false).queue_free()

#Debug
func _on_Button_pressed():
	delete_item()

# Buy Option set
func _on_Buy_pressed():
	set_state("Buy")

#Sell Option Set
func _on_Sell_pressed():
	set_state("Sell")

#Sets state of the option
func set_state(types):
	if(types != shop_setting):
		contents.get_node("Item" + shop_setting).hide()
		shop_setting = types
		contents.get_node("Item" + shop_setting).show()
