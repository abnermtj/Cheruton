extends Control

var count = 0
var active_tab
var active_tab_items
var active_tab_inspector

var item_state = "FREE"
var fixed_node
signal tab_changed(next_tab)

onready var active_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg.png")
onready var index_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png") # to be changed
onready var tab = "BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs"
onready var list = "BorderBackground/InnerBackground/VBoxContainer/MElements"


func _ready():
	DataResource.dict_settings.game_on = false
	$BorderBackground/InnerBackground/VBoxContainer/MElements/Tabs/Coins/CoinsVal.text = str(DataResource.temp_dict_player["coins"])
	load_data()

	connect("tab_changed", self, "change_tab_state")
	emit_signal("tab_changed", "Weapons")

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

func _on_Apparel_pressed():
	if(active_tab != get_node(tab + "/Apparel/Apparel")):
		emit_signal("tab_changed", "Apparel")

func _on_Consum_pressed():
	if(active_tab != get_node(tab + "/Consum/Consum")):
		emit_signal("tab_changed", "Consum")

func _on_Misc_pressed():
	if(active_tab != get_node(tab + "/Misc/Misc")):
		emit_signal("tab_changed", "Misc")

func _on_KeyItems_pressed():
	if(active_tab != get_node(tab + "/KeyItems/KeyItems")):
		emit_signal("tab_changed", "Key Items")

func free_the_inventory():
	DataResource.dict_settings.game_on = true
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()

# mouse enters the area occupied by the node
func _on_mouse_entered(node):
	if(item_state == "FREE"):
		print(node.name)
		node.get_child(0).texture = index_bg
		var insp = retrieve_path_insp()
		#Update Data
		#Weapons/Apparel
		if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
			define_inspector(insp.get_node("ItemInsp2/HBoxContainer/ScrollContainer/Stats"), node)
		#Consume curr
		else: 
			if(active_tab.name == "Consum"):
				define_inspector(insp.get_node("ItemInsp1/HBoxContainer/ScrollContainer/Stats"), node)
			#define_details(insp.get_node("ItemInsp1"), node)
		#Consume/Misc/KeyItems
		if(active_tab.name == "Consum"):
			insp.get_node("ItemInsp1").show()
		insp.get_node("ItemInsp2").show()
		insp.get_node("Buttons").show()

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

#func define_details(defined_node, element_node):
	#defined_node.get_node("Description", element_index)
	
# Mouse leaves label section of the element
func _on_mouse_exited(node):
	if(item_state == "FREE"):
		node.get_child(0).texture = null
		var insp = retrieve_path_insp()
		
		if(active_tab.name == "Consum"):
			insp.get_node("ItemInsp1").hide()
		insp.get_node("ItemInsp2").hide()
		insp.get_node("Buttons").hide()

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

func _on_pressed(node):
	match item_state:
		"FREE":
			item_state = "FIXED"
			fixed_node = node

		"FIXED": 
			if (node != fixed_node):
				fixed_node.get_child(0).texture = null
				fixed_node = node
				if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
					var insp = retrieve_path_insp()
					define_inspector(insp.get_node("ItemInsp2/HBoxContainer/ScrollContainer/Stats"), node)
			else:
				item_state = "FREE"
	if(item_state == "FIXED"): # Highlight the button last pressed
		node.get_child(0).texture = index_bg

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


func delete_item():
	var element_index = str(int(fixed_node.name)%100)
	DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty -= 1
		#delete index
	if (DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty != 0):
		get_node(list + "/" + active_tab.name + "/VBoxCont/" + fixed_node.name + "/Background/MainCont/ItemBg/ItemBtn/Qty").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty)
	else:
		# Item Stock is empty:  Hide its data entry, delete it and shift all the indexes after it down by 1
		var new_index = int(fixed_node.name)/10 * 10 # Convert ones digit to 0
		_on_pressed(fixed_node)
		_on_mouse_exited(fixed_node)
		get_node(list + "/" + str(active_tab.name)+ "/VBoxCont/").get_node(fixed_node.name).queue_free()
		## shift indexes down by 1
		new_index += int(element_index) + 1
		element_index = int(element_index)
		for _i in range(element_index, DataResource.dict_inventory[active_tab.name].size()):
			# erasure working, fix scene
			get_node(list + "/" + str(active_tab.name)+ "/VBoxCont/").get_node(str(new_index)).name = str(new_index - 1)
			DataResource.dict_inventory[active_tab.name]["Item" + str(element_index)] = DataResource.dict_inventory[active_tab.name]["Item" + str(element_index + 1)]
			new_index += 1
			element_index += 1
		print("element")
		print(element_index)
		DataResource.dict_inventory[active_tab.name].erase("Item" + str(element_index))
		print(DataResource.dict_inventory[active_tab.name].size())
