extends Control

var active_tab
var item_state = "HOVER"
var mouse_count = 0
var mouse_node
var shop_setting

signal tab_changed(next_tab)

onready var active_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg.png")
onready var index_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var index_equipped_bg = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_equip.png")

onready var weapons_sell = DataResource.dict_inventory.get("Weapons")
onready var apparel_sell = DataResource.dict_inventory.get("Apparel")
onready var consum_sell = DataResource.dict_inventory.get("Consum")
onready var misc_sell = DataResource.dict_inventory.get("Misc")

onready var weapons_buy = DataResource.dict_item_shop.get("Weapons")
onready var apparel_buy = DataResource.dict_item_shop.get("Apparel")
onready var consum_buy = DataResource.dict_item_shop.get("Consum")
onready var misc_buy = DataResource.dict_item_shop.get("Misc")


onready var contents = $Border/Bg/Main/Rest/Contents
onready var tabs = $Border/Bg/Main/Rest/Contents/Tabs
onready var items_sell = $Border/Bg/Main/Rest/Contents/ItemsSell
onready var items_buy = $Border/Bg/Main/Rest/Contents/ItemsBuy
onready var equipped_coins = $Border/Bg/Main/Rest/Contents/EquippedCoins
onready var item_dec = $Border/Bg/Main/Rest/ItemDec

func _ready():
	DataResource.dict_settings.game_on = false
	connect_tabs()
	set_state("Buy")
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
		contents.get_node("Items" + shop_setting + "/" + active_tab.name).hide()
	
	# Set new active tab and its colour and show its items
	active_tab = new_tab
	active_tab.set_normal_texture(active_tab_image)
	contents.get_node("Items" + shop_setting + "/" + active_tab.name).show()

func load_data():
	#Find subnodes of each tab
	var weapons_scroll_sell = items_sell.get_node("Weapons/Column")
	var apparel_scroll_sell = items_sell.get_node("Apparel/Column")
	var consum_scroll_sell = items_sell.get_node("Consum/Column")
	var misc_scroll_sell = items_sell.get_node("Misc/Column")
	
	var weapons_scroll_buy = items_buy.get_node("Weapons/Column")
	var apparel_scroll_buy = items_buy.get_node("Apparel/Column")
	var consum_scroll_buy = items_buy.get_node("Consum/Column")
	var misc_scroll_buy = items_buy.get_node("Misc/Column")
	
	#Generate list of items based on tab
	generate_list(weapons_scroll_sell, weapons_sell, 100, "Sell")
	generate_list(apparel_scroll_sell, apparel_sell, 200, "Sell")
	generate_list(consum_scroll_sell, consum_sell, 300, "Sell")
	generate_list(misc_scroll_sell, misc_sell, 400, "Sell")
	
	generate_list(weapons_scroll_buy, weapons_buy, 100, "Buy")
	generate_list(apparel_scroll_buy, apparel_buy, 200, "Buy")
	generate_list(consum_scroll_buy, consum_buy, 300, "Buy")
	generate_list(misc_scroll_buy, misc_buy, 400, "Buy")

func generate_list(scroll_tab, list_tab, tab_index, item_dec):
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
		var item_pict
		match item_dec:
			"Sell": 
				if(list_tab["Item" + str(index)].item_qty):
					item.get_node("Background/ItemBg/ItemBtn/Qty").text = str(list_tab["Item" + str(index)].item_qty)
				
				if(list_tab["Item" + str(index)].item_png):
					item_pict  = load(list_tab["Item" + str(index)].item_png)
				
			"Buy":
				var node = DataResource.dict_item_masterlist.get(list_tab["Item" + str(index)])
				if(node.ItemPNG):
					item_pict = load(node.ItemPNG)
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
		node.get_node("Background/ItemBg").texture = null


# When the icon of a item is pressed
func _on_pressed(node):
	if(mouse_count == 0):
		$Timer.start()
	mouse_count += 1
	mouse_node = node
	if (mouse_count == 2):
		print("Double Clicked!")
		match shop_setting:
			"Sell": sell_item()
			"Buy": 
				var index = int(mouse_node.name)%100
				var coins_val = DataResource.dict_item_masterlist[DataResource.dict_item_shop[active_tab.name]["Item" + str(index)]].ItemValue
				if(coins_val <= DataResource.temp_dict_player["coins"]):
					buy_item()
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
		get_node("Border/Bg/Main/Rest/Contents/EquippedCoins/Button").text = shop_setting
		get_node("Border/Bg/Main/Rest/Contents/EquippedCoins/Button").show()
	else:
		item_state = "HOVER"
		get_node("Border/Bg/Main/Rest/Contents/EquippedCoins/Button").hide()
		mouse_node = null

# Reduces qty of item by 1
func sell_item():
	
	var element_index = str(int(mouse_node.name)%100)
	DataFunctions.change_coins(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_value/2)
	equipped_coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])
	DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty -= 1
		#delete index
	if (DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty != 0):
		mouse_node.get_node("Background/ItemBg/ItemBtn/Qty").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty)
	else:

		# Item Stock is empty:
		#	Shift down all inventory entries by 1
		#	Delete the last empty index
		#	If the Row is empty (except Row0), delete it
		
		var main = get_node("Border/Bg/Main/Rest/Contents/ItemsSell/" + active_tab.name)
		if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
			if(DataResource.temp_dict_player[active_tab.name + "_item"] == mouse_node.name):
				DataResource.temp_dict_player[active_tab.name + "_item"] = null
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

# Increases qty of item by 1
func buy_item():
	# contains item type, item name and quantity
	var index = int(mouse_node.name)%100
	var coins_val = DataResource.dict_item_masterlist[DataResource.dict_item_shop[active_tab.name]["Item" + str(index)]].ItemValue
	if(coins_val > DataResource.temp_dict_player["coins"]):
		return
	var item_data = []
	#Append item to inventory
	item_data.append(active_tab.name)
	item_data.append(DataResource.dict_item_shop[active_tab.name]["Item" + str(index)])
	item_data.append(1)
	Loot.loot_dict[1] = item_data
	Loot.append_loot(1)
	# Update coins val and item qty
	
	DataFunctions.change_coins(-coins_val)
	equipped_coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])
	var node = items_sell.find_node(mouse_node.name, true, false)
	node.get_node("Background/ItemBg/ItemBtn/Qty").text = str(DataResource.dict_inventory[active_tab.name]["Item" + str(index)].item_qty)

#Debug
func _on_Button_pressed():
	match shop_setting:
		"Sell": sell_item()
		"Buy": buy_item()
		
# Buy Option set
func _on_Buy_pressed():
	set_state("Buy")
	check_fixed()


#Sell Option Set
func _on_Sell_pressed():
	set_state("Sell")
	check_fixed()


func check_fixed():
	if(item_state == "FIXED"):
		var temp = mouse_node
		revert_item_state()
		_on_mouse_exited(temp)
	

#Sets state of the option
func set_state(types):
	if(types != shop_setting):
		if(shop_setting):
			item_dec.get_node(shop_setting + "/" + shop_setting).set_normal_texture(default_tab_image)
			contents.get_node("Items" + shop_setting + "/" + active_tab.name).hide()
			contents.get_node("Items" + shop_setting).hide()
		shop_setting = types
		item_dec.get_node(shop_setting + "/" + shop_setting).set_normal_texture(active_tab_image)
		if(active_tab):
			contents.get_node("Items" + shop_setting + "/" + active_tab.name).show()
		contents.get_node("Items" + shop_setting).show()
