extends baseGui

var active_tab
var item_state = "HOVER"
var mouse_count = 0
var mouse_node

signal tab_changed(next_tab)
const WEAPONS = 1
const APPAREL = 2
const CONSUM = 3
const MISC = 4
const KEYITEMS = 5

onready var active_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg.png")
onready var index_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var index_equipped_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_equip.png")

onready var weapons_list = DataResource.dict_inventory.get("Weapons")
onready var apparel_list = DataResource.dict_inventory.get("Apparel")
onready var consum_list = DataResource.dict_inventory.get("Consum")
onready var misc_list = DataResource.dict_inventory.get("Misc")
onready var key_items_list = DataResource.dict_inventory.get("Key Items")


onready var tabs = $Border/Bg/Contents/Tabs
onready var items = $Border/Bg/Contents/Items
onready var equipped_coins = $Border/Bg/Contents/EquippedCoins

func _ready():
	connect_tabs()
	load_data()
	emit_signal("tab_changed", "Weapons")
	init_equipped()
	set_equipped()

	equipped_coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])

func _on_Exit_pressed():
	free_the_inventory()

func set_equipped():
	equipped_coins.get_node("Weapons/Background/ItemBg/ItemBtn").connect("pressed", self, "_on_pressed", [equipped_coins.get_node("Weapons")])
	equipped_coins.get_node("Apparel/Background/ItemBg/ItemBtn").connect("pressed", self, "_on_pressed", [equipped_coins.get_node("Apparel")])
	equipped_coins.get_node("Weapons/Background/ItemBg").texture = index_equipped_bg
	equipped_coins.get_node("Apparel/Background/ItemBg").texture = index_equipped_bg

func init_equipped():
	if(DataResource.temp_dict_player.Weapons_item):
		display_equipped("Weapons")

	if(DataResource.temp_dict_player.Apparel_item):
		display_equipped("Apparel")

func display_equipped(name):
	var type = equipped_coins.get_node(name)
	var node = items.find_node(str(DataResource.temp_dict_player[name + "_item"]), true, false)
	type.get_node("Background/ItemBg/ItemBtn").set_normal_texture(node.get_node("Background/ItemBg/ItemBtn").get_normal_texture())
	node.get_node("Background/ItemBg").texture = index_equipped_bg
	type.show()


func free_the_inventory():
	DataResource.save_rest()
	emit_signal("release_gui", "inventory")

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
	if(mouse_node):
		var temp = mouse_node
		revert_item_state()
		_on_mouse_exited(temp)

	if(active_tab):
		active_tab.set_normal_texture(default_tab_image)
		items.get_node(active_tab.name).hide()

	# Set new active tab and its colour and show its items
	active_tab = new_tab
	active_tab.set_normal_texture(active_tab_image)
	items.get_node(active_tab.name).show()

func load_data():
	#Find subnodes of each tab
	var weapons_scroll = items.get_node("Weapons/Column")
	var apparel_scroll = items.get_node("Apparel/Column")
	var consum_scroll = items.get_node("Consum/Column")
	var misc_scroll = items.get_node("Misc/Column")
	var key_items_scroll = items.get_node("KeyItems/Column")

	#Generate list of items based on tab
	generate_list(weapons_scroll, weapons_list, WEAPONS * 100)
	generate_list(apparel_scroll, apparel_list, APPAREL * 100)
	generate_list(consum_scroll, consum_list, CONSUM * 100)
	generate_list(misc_scroll, misc_list, MISC * 100)
	generate_list(key_items_scroll, key_items_list, KEYITEMS * 100)

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
		item.get_node("Background/ItemName").name = list_tab["Item" + str(index)].item_name
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
		utilize_item(node)
		mouse_count = 0

# Use the item that has been double clicked
func utilize_item(node):
	# Dequipping item
	print(node.name)
	if(node.name == "Weapons" || node.name == "Apparel"):
		_item_status(node, "DEQUIP")

	elif(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
		var type = get_node("Border/Bg/Contents/EquippedCoins/" + active_tab.name + "/Background/ItemBg/ItemBtn")
		# Item not equipped or Item Selected is a different weapon
		if(type.get_normal_texture() != node.get_node("Background/ItemBg/ItemBtn").get_normal_texture()):
			_item_status(node, "EQUIP")
		# Removing equipped item
		else:
			_item_status(node, "DEQUIP")
	elif(active_tab.name == "Consum"):
		use_item()

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

	if (DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty != 0):
		mouse_node.get_node("Background/ItemBg/ItemBtn/Qty").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty)
	else:

		# Item Stock is empty:
		#	Dequip item if it is equipped
		#	Shift down all inventory entries by 1
		#	Delete the last empty index
		#	If the Row is empty (except Row0), delete it


		var main = get_node("Border/Bg/Contents/Items/" + active_tab.name)
		if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
			if(DataResource.temp_dict_player[active_tab.name + "_item"] == mouse_node.name):
				DataResource.temp_dict_player[active_tab.name + "_item"] = null
				get_node("Border/Bg/Contents/EquippedCoins/" + active_tab.name).hide()
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

# Handles equipping of the item
func _item_status(selected_node, status):
	var type = get_node("Border/Bg/Contents/EquippedCoins/" + active_tab.name)
	match status:
		"EQUIP":
			type.get_node("Background/ItemBg/ItemBtn").set_normal_texture(selected_node.get_node("Background/ItemBg/ItemBtn").get_normal_texture())
			DataResource.temp_dict_player[active_tab.name + "_item"] = selected_node.name
			selected_node.get_node("Background/ItemBg").texture = index_equipped_bg
			equipped_coins.get_node(active_tab.name + "/Background/ItemBg").texture = index_equipped_bg
			type.show()
			print("Show")
		"DEQUIP":
			if(selected_node.name == "Weapons" || selected_node.name == "Apparel"):
				var actual = items.get_node(selected_node.name + "/Column").find_node(str(DataResource.temp_dict_player[selected_node.name + "_item"]), true, false)
				actual.get_node("Background/ItemBg").texture = null
				selected_node.get_node("Background/ItemBg/ItemBtn").set_normal_texture(null)
				selected_node.hide()
			else:
				selected_node.get_node("Background/ItemBg").texture = null
				type.get_node("Background/ItemBg/ItemBtn").set_normal_texture(null)
				type.hide()
			DataResource.temp_dict_player[active_tab.name + "_item"] = null
			mouse_node = null
			print("Hide")



#Debug
func _on_Button_pressed():
	delete_item()

func handle_input(event):
	if is_active_gui and (Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("inventory")):
		_on_Exit_pressed()
