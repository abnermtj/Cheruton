extends Control

var count = 0
var active_tab
var active_tab_items
var active_tab_inspector
var mouse_count = 0
var mouse_node

var item_state = "FREE"
var fixed_node
signal tab_changed(next_tab)

onready var active_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg.png")
onready var index_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var equipped_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_equip.png")
onready var tab = "BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs"
onready var list = "BorderBackground/InnerBackground/VBoxContainer/MElements"


func _ready():
	DataResource.dict_settings.game_on = false
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Coins/CoinsVal.text = str(DataResource.temp_dict_player["coins"])
	load_data()

	connect("tab_changed", self, "change_tab_state")
	emit_signal("tab_changed", "Weapons")
	update_equipped_item("INIT")

	get_node(list + "/InspWeapons/Buttons/Delete").connect("pressed", self,  "delete_item")
	get_node(list +"/InspApparel/Buttons/Delete").connect("pressed", self,  "delete_item")
	get_node(list + "/InspConsum/Buttons/Delete").connect("pressed", self,  "delete_item")
	get_node(list + "/InspMisc/Buttons/Delete").connect("pressed", self,  "delete_item")

	# Hide initbar() to view inventory directly
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/ExpBar.initbar()
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/HealthBar.initbar()


func load_data():
	# Get data according to relevant sections
	var weapons_list = DataResource.dict_inventory.get("Weapons")
	var apparel_list = DataResource.dict_inventory.get("Apparel")
	var consum_list = DataResource.dict_inventory.get("Consum")
	var misc_list = DataResource.dict_inventory.get("Misc")
	var key_items_list = DataResource.dict_inventory.get("Key Items")

	#Find subnodes of each tab
	var weapons_scroll = list + "/Weapons/VBoxCont/"
	var apparel_scroll = list + "/Apparel/VBoxCont/"
	var consum_scroll = list + "/Consum/VBoxCont/"
	var misc_scroll = list + "/Misc/VBoxCont/"
	var key_items_scroll = list + "/KeyItems/VBoxCont/"

	#Generate list of items based on tab
	generate_list(weapons_scroll, weapons_list, 100)
	generate_list(apparel_scroll, apparel_list, 200)
	generate_list(consum_scroll, consum_list, 300)
	generate_list(misc_scroll, misc_list, 400)
	generate_list(key_items_scroll, key_items_list, 500)


func generate_list(scroll_tab, list_tab, tab_index):
	var index = 1
	for _i in range(0, list_tab.size()):
		if(!has_node(scroll_tab + str(tab_index + index))):
			var instance_loc = load("res://Player/Inventory/101.tscn")
			var instanced = instance_loc.instance()
			get_node(scroll_tab).add_child(instanced)
			get_node(scroll_tab).get_child(get_node(scroll_tab).get_child_count() - 1).name = str(tab_index + index)

		#need to add the pic of the item also
		get_node(scroll_tab + str(tab_index + index) + "/Background/MainCont/ItemBg/ItemBtn/Qty").text = str(list_tab["Item" + str(index)].item_qty)
		get_node(scroll_tab + str(tab_index + index) + "/Background/MainCont/ItemName").text = list_tab["Item" + str(index)].item_name
		var new_node = get_node(scroll_tab + str(tab_index + index))

		enable_mouse(new_node)
		index += 1

# Updates the equipped item (Weapons/Apparel)
func update_equipped_item(scenario):
	var insp_address = retrieve_path_insp().get_node("ItemInsp1/HBoxContainer/ScrollContainer/Stats")
	var address = retrieve_path_insp().get_node("ItemInsp1")
	var element_index
	#Update data displayed
	match scenario:
		"REPLACE":
			print("Replacing Item!")
			if(DataResource.temp_dict_player[active_tab.name + "_item"]): #there is an item equipped
				get_node(list + "/"  + active_tab.name + "/VBoxCont/" + str(DataResource.temp_dict_player[active_tab.name + "_item"])).get_child(0).texture = null # bg of old texture
			if(fixed_node):
				DataResource.temp_dict_player[active_tab.name + "_item"] = fixed_node.name
			else:
				DataResource.temp_dict_player[active_tab.name + "_item"] = mouse_node.name
			element_index = str(int(DataResource.temp_dict_player[active_tab.name + "_item"]) % 100)
			slot_data(insp_address, element_index)

			get_node(list + "/"  + active_tab.name + "/VBoxCont/" + str(DataResource.temp_dict_player[active_tab.name + "_item"])).get_child(0).texture = equipped_bg#stub-to be changed
			item_state = "FREE"
			fixed_node = null
			address.show()

		"INIT":
			print("Displaying Item!")
			if(!DataResource.temp_dict_player[active_tab.name + "_item"]): # Item not equipped
				print("No item equipped")
				return
			element_index = str(int(DataResource.temp_dict_player[active_tab.name + "_item"]) % 100)
			slot_data(insp_address, element_index)
			get_node(list + "/"  + active_tab.name + "/VBoxCont/" + str(DataResource.temp_dict_player[active_tab.name + "_item"])).get_child(0).texture = equipped_bg#stub-to be changed
			address.show()

		"REMOVE":
			print("Removing Item!")
			get_node(list + "/"  + active_tab.name + "/VBoxCont/" + str(DataResource.temp_dict_player[active_tab.name + "_item"])).get_child(0).texture = null
			DataResource.temp_dict_player[active_tab.name + "_item"] = null
			item_state = "FREE"
			fixed_node = null
			address.hide()

# Slots data into the equipped item's item inspector
func slot_data(insp_address, element_index):
	insp_address.get_node("Attack/StatVal").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_attack)
	insp_address.get_node("Defense/StatVal").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_defense)
	insp_address.get_node("Val/StatVal").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_value)

func _on_Equip_pressed():
	var insp = retrieve_path_insp()
	if(mouse_count == 2 || (fixed_node && fixed_node.name != str(DataResource.temp_dict_player[active_tab.name + "_item"])) || !DataResource.temp_dict_player[active_tab.name + "_item"]):
		update_equipped_item("REPLACE")
		insp.get_node("ItemInsp2").hide()
		insp.get_node("Buttons").hide()

	else:
		update_equipped_item("REMOVE")
		insp.get_node("ItemInsp2").hide()
		insp.get_node("Buttons").hide()

# Enable mouse functions of the item index
func enable_mouse(new_node):

		new_node.get_node("Background/MainCont/ItemBg/ItemBtn").connect("pressed", self, "_on_pressed", [new_node])
		new_node.connect("mouse_entered", self, "_on_mouse_entered", [new_node])
		new_node.connect("mouse_exited", self, "_on_mouse_exited", [new_node])

		# For the TextureButton
		new_node.get_node("Background/MainCont/ItemBg/ItemBtn").connect("mouse_entered", self, "_on_mouse_entered", [new_node])
		new_node.get_node("Background/MainCont/ItemBg/ItemBtn").connect("mouse_exited", self, "_on_mouse_exited", [new_node])

func _on_Exit_pressed():
	free_the_inventory()

func change_tab_state(next_tab):
	match next_tab:
		"Weapons":   change_active_tab(get_node(tab + "/Weapons/Weapons"), get_node(list + "/Weapons"), get_node(list + "/InspWeapons"))
		"Apparel":   change_active_tab(get_node(tab + "/Apparel/Apparel"), get_node(list + "/Apparel"), get_node(list + "/InspApparel"))
		"Consum":    change_active_tab(get_node(tab + "/Consum/Consum"), get_node(list + "/Consum"), get_node(list + "/InspConsum"))
		"Misc":      change_active_tab(get_node(tab + "/Misc/Misc"), get_node(list + "/Misc"), get_node(list + "/InspMisc"))
		"Key Items": change_active_tab(get_node(tab + "/KeyItems/KeyItems"), get_node(list + "/KeyItems"), get_node(list + "/InspKeyItems"))
	if(fixed_node):
		fixed_node.get_child(0).texture = null
		item_state = "FREE"
		fixed_node = null


	if(next_tab):
		print("Current Tab: ")
		print(next_tab)

func change_active_tab(new_tab, items_list, insp_panel):
	# Set current tab to default colour and hide its items
	if(active_tab):
		active_tab.set_normal_texture(default_tab_image)
		active_tab_items.hide()
		active_tab_inspector.hide()

	# Set new active tab and its colour and show its items
	active_tab = new_tab
	active_tab_items = items_list
	active_tab_inspector = insp_panel

	active_tab.set_normal_texture(active_tab_image)
	active_tab_items.show()
	active_tab_inspector.show()

func _on_Weapons_pressed():
	if(active_tab != get_node(tab + "/Weapons/Weapons")):
		emit_signal("tab_changed", "Weapons")
		update_equipped_item("INIT")

func _on_Apparel_pressed():
	if(active_tab != get_node(tab + "/Apparel/Apparel")):
		emit_signal("tab_changed", "Apparel")
		update_equipped_item("INIT")

func _on_Consum_pressed():
	if(active_tab != get_node(tab + "/Consum/Consum")):
		emit_signal("tab_changed", "Consum")

func _on_Misc_pressed():
	if(active_tab != get_node(tab + "/Misc/Misc")):
		emit_signal("tab_changed", "Misc")

func _on_KeyItems_pressed():
	if(active_tab != get_node(tab + "/KeyItems/KeyItems")):
		emit_signal("tab_changed", "Key Items")

# Removes the instance of the whole inventory system
func free_the_inventory():
	DataResource.dict_settings.game_on = true
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()

# mouse enters the area occupied by the node
func _on_mouse_entered(node):
	if(item_state == "FREE"):
		mouse_node = node
		print(node.name)
		if(!((active_tab.name == "Weapons" || active_tab.name == "Apparel") && node.name == str(DataResource.temp_dict_player[active_tab.name + "_item"]))):
			node.get_child(0).texture = index_bg
		var insp = retrieve_path_insp()
		#Update Data
		#Weapons/Apparel
		if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
			define_inspector(insp.get_node("ItemInsp2/HBoxContainer/ScrollContainer/Stats"), node)
			if(node.name == str(DataResource.temp_dict_player[active_tab.name + "_item"])): # Accessing item alr equipped
				insp.get_node("Buttons/Equip/Equip/Equip").text = "Remove"
			else:# Accessing item not equipped
				insp.get_node("Buttons/Equip/Equip/Equip").text = "Equip"
		#Consume/Misc/KeyItems
		else:
			if(active_tab.name == "Consum"):
				define_inspector(insp.get_node("ItemInsp1/HBoxContainer/ScrollContainer/Stats"), node)
			var element_index = str(int(node.name)%100)
			insp.get_node("ItemInsp2/Description").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_details)

		if(active_tab.name == "Consum"):
			insp.get_node("ItemInsp1").show()
		elif(node.name != str(DataResource.temp_dict_player[active_tab.name + "_item"])):
			insp.get_node("ItemInsp2").show()
		insp.get_node("Buttons").show()

# Mouse leaves label section of the element
func _on_mouse_exited(node):
	if(!node):
		return
	if(item_state == "FREE"):
		if(!((active_tab.name == "Weapons" || active_tab.name == "Apparel") && node.name == str(DataResource.temp_dict_player[active_tab.name + "_item"]))):
			node.get_child(0).texture = null
		var insp = retrieve_path_insp()

		if(active_tab.name == "Consum"):
			insp.get_node("ItemInsp1").hide()
		insp.get_node("ItemInsp2").hide()
		insp.get_node("Buttons").hide()

# When the icon of a item is pressed
func _on_pressed(node):
	if(mouse_count == 0):
		$Timer.start()
	mouse_count += 1
	if (mouse_count == 2):
		print("Double Clicked!")
		if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
			_on_Equip_pressed()
		mouse_count = 0


# Check if the doubleclick has happened
func _on_Timer_timeout():
	if(mouse_count == 1):
		print("Single Clicked!")
		change_state(mouse_node)
		mouse_count = 0


func change_state(node):
	if(!node):
		return
	match item_state:
		"FREE":
			item_state = "FIXED"
			fixed_node = node

		"FIXED":
			if (node != fixed_node):
				fixed_node = node
			else:
				item_state = "FREE"

	if(item_state == "FIXED" && !((active_tab.name == "Weapons" || active_tab.name == "Apparel") && node.name == str(DataResource.temp_dict_player[active_tab.name + "_item"]))): # Highlight the button last pressed
		node.get_child(0).texture = index_bg


# Displays the respective data corresponding to the item
func define_inspector(defined_node, node):
	var element_index = str(int(node.name)%100)
	if(active_tab.name == "Consum"):
		defined_node.get_node("StatInc/StatVal").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_statheal)
		defined_node.get_node("Boost/StatVal").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_healval)
	else:
		defined_node.get_node("Attack/StatVal").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_attack)
		defined_node.get_node("Defense/StatVal").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_defense)
	defined_node.get_node("Val/StatVal").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_value)


func retrieve_path_insp():
	match active_tab.name:
		"Weapons":
			return $BorderBackground/InnerBackground/VBoxContainer/MElements/InspWeapons
		"Apparel":
			return $BorderBackground/InnerBackground/VBoxContainer/MElements/InspApparel
		"Consum":
			return $BorderBackground/InnerBackground/VBoxContainer/MElements/InspConsum
		"Misc":
			return $BorderBackground/InnerBackground/VBoxContainer/MElements/InspMisc
		"KeyItems":
			return $BorderBackground/InnerBackground/VBoxContainer/MElements/InspKeyPass



#Use a Consum item
func _on_Use_pressed():
	var element_index = str(int(fixed_node.name)%100)
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
	var name_node

	if(fixed_node): #Delete normal item
		name_node = fixed_node.name
	else: #Delete equipped item
		name_node = str(DataResource.temp_dict_player[active_tab.name + "_item"])
	var element_index = str(int(name_node)%100)
	DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty -= 1
		#delete index
	if (DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty != 0):
		get_node(list + "/" + active_tab.name + "/VBoxCont/" + name_node + "/Background/MainCont/ItemBg/ItemBtn/Qty").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty)
	else:
		# Item Stock is empty:
		# Item is currently equipped
		if(!fixed_node):
			update_equipped_item("REMOVE")
		element_index = int(element_index)
		var scene_index = element_index - 1

		_on_pressed(fixed_node)
		_on_mouse_exited(fixed_node)
		#Hide its data entry, delete it immediately and shift all the indexes after it down by 1
		get_node(list + "/" + str(active_tab.name)+ "/VBoxCont").get_child(scene_index).free()

		for _i in range(element_index, DataResource.dict_inventory[active_tab.name].size()):

			var scene_name = get_node(list + "/" + str(active_tab.name)+ "/VBoxCont").get_child(scene_index)
			scene_name.name = str(int(scene_name.name) - 1)
			DataResource.dict_inventory[active_tab.name]["Item" + str(element_index)] = DataResource.dict_inventory[active_tab.name]["Item" + str(element_index + 1)]
			scene_index += 1
			element_index += 1
		DataResource.dict_inventory[active_tab.name].erase("Item" + str(element_index))







