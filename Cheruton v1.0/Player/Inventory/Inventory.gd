extends basePopUp

const WEAPONS = 100
const APPAREL = 200
const CONSUM = 300
const MISC = 400
const KEYITEMS = 500
const BOXES = 50

var active_tab
var item_state = "HOVER"
var mouse_count = 0
var mouse_node
var temp_mouse_node

onready var active_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg.png")
onready var index_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var index_equipped_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_equip.png")
onready var instance_loc = preload("res://Player/Inventory/101.tscn")

onready var weapons_list = DataResource.dict_inventory.get("Weapons")
onready var apparel_list = DataResource.dict_inventory.get("Apparel")
onready var consum_list = DataResource.dict_inventory.get("Consum")
onready var misc_list = DataResource.dict_inventory.get("Misc")
onready var key_items_list = DataResource.dict_inventory.get("Key Items")

onready var inventory = self
onready var shop = get_parent().get_node("shop")
onready var tabs = $Border/Bg/Contents/Tabs
onready var items = $Border/Bg/Contents/Items
onready var equipped_coins = $Border/Bg/Contents/EquippedCoins

signal tab_changed(next_tab)

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
	var _conn1 = equipped_coins.get_node("Weapons/Background/ItemBg/ItemBtn").connect("pressed", inventory, "_on_pressed", [equipped_coins.get_node("Weapons")])
	var _conn2 = equipped_coins.get_node("Apparel/Background/ItemBg/ItemBtn").connect("pressed", inventory, "_on_pressed", [equipped_coins.get_node("Apparel")])
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
	var _conn1 = connect("tab_changed", inventory, "change_tab_state")
	tabs.get_node("Weapons/Weapons").connect("pressed",inventory,  "tab_pressed", ["Weapons"])
	tabs.get_node("Apparel/Apparel").connect("pressed", inventory,  "tab_pressed", ["Apparel"])
	tabs.get_node("Consum/Consum").connect("pressed", inventory,  "tab_pressed", ["Consum"])
	tabs.get_node("Misc/Misc").connect("pressed", inventory,  "tab_pressed", ["Misc"])
	tabs.get_node("KeyItems/KeyItems").connect("pressed", inventory,  "tab_pressed", ["KeyItems"])

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
	generate_list(weapons_scroll, weapons_list, WEAPONS)
	generate_list(apparel_scroll, apparel_list, APPAREL)
	generate_list(consum_scroll, consum_list, CONSUM)
	generate_list(misc_scroll, misc_list, MISC)
	generate_list(key_items_scroll, key_items_list, KEYITEMS)

func generate_list(scroll_tab, list_tab, tab_index):
	var index = 1
	var row_index = -1
	var dict_size = list_tab.size()
	for _i in range(0, BOXES):

		# Creates New Row every 10 items
		if(index / 10 != row_index && index % 10 != 0):
			var new_row = HBoxContainer.new()
			row_index += 1
			scroll_tab.add_child(new_row)
			scroll_tab.get_child(scroll_tab.get_child_count() - 1).name = "Row" + str(row_index)

		var row = scroll_tab.get_node("Row" + str(row_index))

		# Creates a new box in the particular row
		var instanced = instance_loc.instance()
		row.add_child(instanced)
		row.get_child(row.get_child_count() - 1).name = str(tab_index + index)

		var item = row.get_node(str(tab_index + index))

		# Populates the boxes based on the no. of items in that particular tab
		if(index <= dict_size):
			#Add properties
			enable_mouse(item)
			generate_specific_data(item, index, list_tab)

		index += 1

# Generates the specific statistics relevant to the item node
func generate_specific_data(item_index_node, item_index, list_tab):
	item_index_node.get_child(0).get_child(0).name = list_tab["Item" + str(item_index)].item_name
	if(list_tab["Item" + str(item_index)].item_qty):
		item_index_node.get_node("Background/ItemBg/ItemBtn/Qty").text = str(list_tab["Item" + str(item_index)].item_qty)

	if(list_tab["Item" + str(item_index)].item_png):
		var item_pict  = load(list_tab["Item" + str(item_index)].item_png)
		item_index_node.get_node("Background/ItemBg/ItemBtn").set_normal_texture(item_pict)


# Enable mouse functions of the item index
func enable_mouse(new_node, buying:= false):

		var btn = new_node.get_node("Background/ItemBg/ItemBtn")
		btn.get_node("Qty").show()
		if(!btn.get_normal_texture() || buying):
			var _conn_0 = btn.connect("pressed", inventory, "_on_pressed", [new_node])
			var _conn_1 = new_node.connect("mouse_entered", inventory, "_on_mouse_entered", [new_node])
			var _conn_2 = new_node.connect("mouse_exited", inventory, "_on_mouse_exited", [new_node])

			# For the TextureButton
			var _conn_3 = btn.connect("mouse_entered", inventory, "_on_mouse_entered", [new_node])
			var _conn_4 = btn.connect("mouse_exited", inventory, "_on_mouse_exited", [new_node])

# Disable mouse functions of the item index
func disable_mouse(new_node):
		# Clear item stats
		var btn = new_node.get_node("Background/ItemBg/ItemBtn")
		btn.get_parent().get_parent().get_child(0).name = "ItemName"
		btn.get_node("Qty").text = "0"
		btn.get_node("Qty").hide()
		btn.set_normal_texture(null)

		var _disconn_1 = btn.disconnect("pressed", inventory, "_on_pressed")
		var _disconn_2 = new_node.disconnect("mouse_entered",inventory, "_on_mouse_entered")
		var _disconn_3 = new_node.disconnect("mouse_exited", inventory, "_on_mouse_exited")

		# For the TextureButton
		var _disconn_4 = btn.disconnect("mouse_entered", inventory, "_on_mouse_entered")
		var _disconn_5 = btn.disconnect("mouse_exited", inventory, "_on_mouse_exited")


func _on_mouse_entered(node):
	if(mouse_node != node):
		node.get_node("Background/ItemBg").texture = index_bg


# Mouse leaves label section of the element
func _on_mouse_exited(node):
	if(mouse_node != node):
		change_mouse_bg(node)

# Changes based on whether if the item is equipped or not
func change_mouse_bg(node):
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
	temp_mouse_node = node

	if (mouse_count == 2):
		mouse_node = temp_mouse_node
		utilize_item(node)
		check_fixed()	# Revert back to hover status
		mouse_count = 0

func check_fixed():
	if(item_state == "FIXED"):
		var temp = mouse_node
		revert_item_state()
		_on_mouse_exited(temp)

# Use the item that has been double clicked
func utilize_item(node):
	# Dequipping item
	if(node.name == "Weapons" || node.name == "Apparel"):
		item_status(node, "DEQUIP")

	elif(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
		var type = get_node("Border/Bg/Contents/EquippedCoins/" + active_tab.name + "/Background/ItemBg/ItemBtn")
		# Item not equipped or Item Selected is a different weapon
		if(type.get_normal_texture() != node.get_node("Background/ItemBg/ItemBtn").get_normal_texture()):
			item_status(node, "EQUIP")
		# Removing equipped item
		else:
			item_status(node, "DEQUIP")
	elif(active_tab.name == "Consum"):
		use_item()

# Check if the doubleclick has happened
func _on_Timer_timeout():
	if(mouse_count == 1):
		revert_item_state()
		mouse_count = 0

func revert_item_state():
	# Initially Hover
	if(item_state == "HOVER"):
		mouse_node = temp_mouse_node
		item_state = "FIXED"
		mouse_node.get_node("Background/ItemBg").texture = index_bg
		get_node("Border/Bg/Contents/EquippedCoins/Button").show()

	# Initially Fixed
	elif(mouse_node != temp_mouse_node):
		change_mouse_bg(mouse_node)

	else:
		item_state = "HOVER"
		get_node("Border/Bg/Contents/EquippedCoins/Button").hide()
		mouse_node = null

func use_item():
	var element_index = str(int(mouse_node.name)%100)
	var item_used = false
	if (DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_statheal == "EXP"):
		DataResource.add_exp(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_healval)
		item_used = true
	elif(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_statheal == "HP" && DataResource.temp_dict_player.health_curr != DataResource.temp_dict_player.health_max):
		DataResource.change_health(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_healval)
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

		# Dequips active item
		var main = get_node("Border/Bg/Contents/Items/" + active_tab.name)
		if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
			if(DataResource.temp_dict_player[active_tab.name + "_item"] == mouse_node.name):
				DataResource.temp_dict_player[active_tab.name + "_item"] = null
				get_node("Border/Bg/Contents/EquippedCoins/" + active_tab.name).hide()

		# From deleted item's index upwards, shift affected indexes down by 1
		var list_tab = DataResource.dict_inventory[active_tab.name]
		var dict_size = list_tab.size()
		element_index = int(element_index)
		for _i in range(element_index, dict_size):
			DataResource.dict_inventory[active_tab.name]["Item" + str(element_index)] = DataResource.dict_inventory[active_tab.name]["Item" + str(element_index + 1)]
			var updating_node_index = str(int(mouse_node.name)/100 * 100 + element_index)
			var updating_node = items.get_node(active_tab.name).find_node(updating_node_index, true, false)

			generate_specific_data(updating_node, element_index, list_tab)
			element_index += 1

		# Disabled the last node which is emptied
		DataResource.dict_inventory[active_tab.name].erase("Item" + str(element_index))
		var deletion = str(int(mouse_node.name)/100 * 100 + element_index)
		var emptied_node = items.get_node(active_tab.name).find_node(deletion, true, false)
		check_fixed()
		disable_mouse(emptied_node)

		equipped_coins.get_node("Button").hide()

# Handles equipping of the item
func item_status(selected_node, status):
	var type = get_node("Border/Bg/Contents/EquippedCoins/" + active_tab.name)
	match status:
		"EQUIP":
			type.get_node("Background/ItemBg/ItemBtn").set_normal_texture(selected_node.get_node("Background/ItemBg/ItemBtn").get_normal_texture())
			DataResource.temp_dict_player[active_tab.name + "_item"] = selected_node.name
			selected_node.get_node("Background/ItemBg").texture = index_equipped_bg
			equipped_coins.get_node(active_tab.name + "/Background/ItemBg").texture = index_equipped_bg
			type.show()
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

#Debug
func _on_Button_pressed():
	delete_item()

func handle_input(event):
	if is_active_gui and (Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("inventory")):
		_on_Exit_pressed()

# Updates inventory changes to the Shop items to sell for future
func _on_Inventory_visibility_changed():
	if(!visible):
		check_fixed()
		var shop_sell = get_parent().find_node("ItemsSell", true, false)
		update_tab_items(WEAPONS, shop_sell, "Weapons")
		update_tab_items(APPAREL, shop_sell, "Apparel")
		update_tab_items(CONSUM, shop_sell, "Consum")
		update_tab_items(MISC, shop_sell, "Misc")
	else:
		equipped_coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])


# Updates a particular tabs item stock
func update_tab_items(tab_constant, updating_path, tab_name):
		var element_index = 1
		var list_tab = DataResource.dict_inventory[tab_name]
		var dict_size = list_tab.size() + 1
		var updating_node_index
		var updating_node
		for _i in range(element_index, dict_size):
			updating_node_index = str(int(tab_constant + element_index))
			updating_node = updating_path.get_node(tab_name).find_node(updating_node_index, true, false)
			generate_specific_data(updating_node, element_index, list_tab)
			element_index += 1
		if(element_index == dict_size):
			updating_node_index = str(int(tab_constant + element_index))
			updating_node = updating_path.get_node(tab_name).find_node(updating_node_index, true, false)
			if(updating_node.get_child(0).get_child(0).name != "ItemName"):
				shop.disable_mouse(updating_node)
