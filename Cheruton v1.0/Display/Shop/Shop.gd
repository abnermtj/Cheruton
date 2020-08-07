extends basePopUp

const WEAPONS = 100
const APPAREL = 200
const CONSUM = 300
const MISC = 400
const BOXES = 50
const EMPTY = "0"

var active_tab
var item_state = "HOVER"
var mouse_count = 0
var mouse_node
var shop_setting
var temp_mouse_node

signal tab_changed(next_tab)

onready var active_tab_image = preload("res://Display/Shop/Sprites/Slots/HorizontalTabSelect.png")
onready var default_tab_image = preload("res://Display/Shop/Sprites/Slots/HorizontalTabDeSelect.png")
onready var index_bg = preload("res://Display/Shop/Sprites/Slots/itemSelected.png")
onready var index_equipped_bg = preload("res://Display/Shop/Sprites/Slots/itemEquipped.png")
onready var instance_loc = preload("res://Player/Inventory/101.tscn")

onready var weapons_sell = DataResource.dict_inventory.get("Weapons")
onready var apparel_sell = DataResource.dict_inventory.get("Apparel")
onready var consum_sell = DataResource.dict_inventory.get("Consum")
onready var misc_sell = DataResource.dict_inventory.get("Misc")

onready var shop = self
onready var inventory = get_parent().get_node("inventory")

onready var contents = $Border/Bg/Main/Sides/Rest/Contents
onready var tabs = $Border/Bg/Main/Sides/Rest/Contents/Tabs
onready var items_sell = $Border/Bg/Main/Sides/Rest/Contents/ItemsSell
onready var items_buy = $Border/Bg/Main/Sides/Rest/Contents/ItemsBuy
onready var coins = $Border/Bg/Main/Sides/Data/Coins
onready var price_value = $Border/Bg/Main/Sides/Data/Price/Value
onready var buy_tab = $Border/Bg/Main/Sides/BtnMode/Buy
onready var sell_tab = $Border/Bg/Main/Sides/BtnMode/Sell

onready var transaction_music = $MusicNodes/Transaction
onready var hover_music = $MusicNodes/Hover
onready var select_music = $MusicNodes/Select



func _ready():
	connect_tabs()
	_on_Buy_pressed()
	
	load_data()
	init_equipped()
	emit_signal("tab_changed", "Weapons")

	coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])
	price_value.text = EMPTY

# Links the buttons when pressed into the function to change active tab
func connect_tabs():
	var _conn0 = connect("tab_changed", shop, "change_tab_state")
	var _conn1 = tabs.get_node("Weapons/Weapons").connect("pressed", shop,  "tab_pressed", ["Weapons"])
	var _conn2 = tabs.get_node("Apparel/Apparel").connect("pressed", shop,  "tab_pressed", ["Apparel"])
	var _conn3 = tabs.get_node("Consum/Consum").connect("pressed", shop,  "tab_pressed", ["Consum"])
	var _conn4 = tabs.get_node("Misc/Misc").connect("pressed", shop,  "tab_pressed", ["Misc"])

# Buy Option set
func _on_Buy_pressed():
	if(shop_setting == "Sell" || !shop_setting):
		sell_tab.texture_normal = default_tab_image
		buy_tab.texture_normal = active_tab_image
		tabs.hide()
		set_state("Buy")
		check_fixed()
	print("Ok")

#Sell Option Set
func _on_Sell_pressed():
	if(shop_setting == "Buy"):
		buy_tab.texture_normal = default_tab_image
		sell_tab.texture_normal = active_tab_image
		tabs.show()
		set_state("Sell")
		check_fixed()

#Sets state of the option
func set_state(types):
	if(types != shop_setting):
		if(shop_setting):
			contents.get_node("Items" + shop_setting).hide()
		shop_setting = types
		contents.get_node("Items" + shop_setting).show()

func check_fixed():
	if(item_state == "FIXED"):
		var temp = mouse_node
		revert_item_state()
		_on_mouse_exited(temp)

func load_data():
	#Find subnodes of each tab
	var weapons_scroll_sell = items_sell.get_node("Weapons/Column")
	var apparel_scroll_sell = items_sell.get_node("Apparel/Column")
	var consum_scroll_sell = items_sell.get_node("Consum/Column")
	var misc_scroll_sell = items_sell.get_node("Misc/Column")

	var scroll_buy = items_buy.get_node("General/Column")

	#Generate list of items based on tab
	generate_list(weapons_scroll_sell, weapons_sell, 100, "Sell")
	generate_list(apparel_scroll_sell, apparel_sell, 200, "Sell")
	generate_list(consum_scroll_sell, consum_sell, 300, "Sell")
	generate_list(misc_scroll_sell, misc_sell, 400, "Sell")

	generate_list(scroll_buy, DataResource.dict_item_shop, 100, "Buy")

func generate_list(scroll_tab, list_tab, tab_index, item_dec):
	var index = 1
	var row_index = -1
	var dict_size = list_tab.size()
	for _i in range(0, BOXES):

		# Creates New Row every 10 items
		if(index %6 == 1):
			var new_row = HBoxContainer.new()
			row_index += 1
			scroll_tab.add_child(new_row)
			var integrated_row = scroll_tab.get_child(scroll_tab.get_child_count() - 1)
			integrated_row.name = "Row" + str(row_index)
			integrated_row.add_constant_override("separation", 10)

		var row = scroll_tab.get_node("Row" + str(row_index))

		# Creates a new box in the particular row
		var instanced = instance_loc.instance()
		row.add_child(instanced)
		row.get_child(row.get_child_count() - 1).name = str(tab_index + index)

		var item = row.get_node(str(tab_index + index))

		# Populates the boxes based on the no. of items in that particular tab
		if(index <= dict_size):
			#Add properties
			var item_pict
			enable_mouse(item)
			match item_dec:
				"Sell":
					generate_specific_data(item, index, list_tab)

				"Buy":
					var node = DataResource.dict_item_masterlist.get(list_tab["Item" + str(index)])
					item.get_node("Background/ItemName").name = list_tab["Item" + str(index)]
					if(node.ItemPNG):
						item_pict = load(node.ItemPNG)
					item.get_node("Background/ItemBg/ItemBtn").set_normal_texture(item_pict)

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
func enable_mouse(new_node):
		var btn = new_node.get_node("Background/ItemBg/ItemBtn")
		btn.get_node("Qty").show()
		if(!btn.get_normal_texture()):
			var _conn0 = btn.connect("pressed", shop, "_on_pressed", [new_node])
			var _conn1 = new_node.connect("mouse_entered", shop, "_on_mouse_entered", [new_node])
			var _conn2 = new_node.connect("mouse_exited", shop, "_on_mouse_exited", [new_node])

			# For the TextureButton
			var _conn3 = btn.connect("mouse_entered", shop, "_on_mouse_entered", [new_node])
			var _conn4 = btn.connect("mouse_exited", shop, "_on_mouse_exited", [new_node])

# Disable mouse functions of the item index
func disable_mouse(new_node):
		# Clear item stats
		var btn = new_node.get_node("Background/ItemBg/ItemBtn")
		btn.get_parent().get_parent().get_child(0).name = "ItemName"
		btn.get_node("Qty").text = "0"
		btn.get_node("Qty").hide()
		btn.set_normal_texture(null)

		var _disconn1 = btn.disconnect("pressed", shop, "_on_pressed")
		var _disconn2 = new_node.disconnect("mouse_entered", shop, "_on_mouse_entered")
		var _disconn3 = new_node.disconnect("mouse_exited", shop, "_on_mouse_exited")

		# For the TextureButton
		var _disconn4 = btn.disconnect("mouse_entered", shop, "_on_mouse_entered")
		btn.disconnect("mouse_exited", shop, "_on_mouse_exited")


func init_equipped():
	if(DataResource.temp_dict_player.Weapons_item):
		display_equipped("Weapons")

	if(DataResource.temp_dict_player.Apparel_item):
		display_equipped("Apparel")

# Displays equipped item if it was equipped in the shop
func display_equipped(name):
	var node = items_sell.find_node(str(DataResource.temp_dict_player[name + "_item"]), true, false)
	node.get_node("Background/ItemBg").texture = index_equipped_bg


func tab_pressed(next_tab):
	if(active_tab.name != next_tab):
		emit_signal("tab_changed", next_tab)

func change_tab_state(next_tab):
	match next_tab:
		"Weapons":   change_active_tab(tabs.get_node("Weapons"))
		"Apparel":   change_active_tab(tabs.get_node("Apparel"))
		"Consum":    change_active_tab(tabs.get_node("Consum"))
		"Misc":      change_active_tab(tabs.get_node("Misc"))

# Toggles active tab of items to be sold
func change_active_tab(new_tab):
	# Set current tab to default colour and hide its items
	if(mouse_node):
		var temp = mouse_node
		revert_item_state()
		_on_mouse_exited(temp)

	if(active_tab):
		active_tab.texture = default_tab_image
		contents.get_node("ItemsSell/" + active_tab.name).hide()
		price_value.text = EMPTY

	# Set new active tab and its colour and show its items
	active_tab = new_tab
	active_tab.texture = active_tab_image
	contents.get_node("ItemsSell/" + active_tab.name).show()

func _on_mouse_entered(node):
	if(mouse_node != node):
		hover_music.play()
		node.get_node("Background/ItemBg").texture = index_bg
		var index = int(node.name) % 100
		if(shop_setting == "Buy"):
			price_value.text = str(DataResource.dict_item_masterlist[DataResource.dict_item_shop["Item" + str(index)]].ItemValue)
		else:
			price_value.text = str(DataResource.dict_inventory[active_tab.name]["Item" + str(index)].item_value/2)
# Mouse leaves label section of the element
func _on_mouse_exited(node):
	if(mouse_node != node):
		change_mouse_bg(node)
		price_value.text = EMPTY


func change_mouse_bg(node):
	if((active_tab.name == "Weapons" || active_tab.name == "Apparel") && shop_setting == "Sell"):
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
		check_fixed()
		mouse_node = temp_mouse_node
		match shop_setting:
			"Sell": 	# Sell item: fix the item, then sell it
				if(item_state == "HOVER"):
					revert_item_state()
				sell_item()

			"Buy":		# Buy item: get node details, fix the item, then sell it
				var index = int(mouse_node.name)%100
				var coins_val = DataResource.dict_item_masterlist[DataResource.dict_item_shop["Item" + str(index)]].ItemValue
				if(item_state == "HOVER"):
					revert_item_state()
				if(coins_val <= DataResource.temp_dict_player["coins"]):
					buy_item()
		price_value.text = EMPTY
		check_fixed()	# Revert back to hover status
		mouse_count = 0


# Check if the doubleclick has happened
func _on_Timer_timeout():
	if(mouse_count == 1):
		select_music.play()
		revert_item_state()
		mouse_count = 0

func revert_item_state():
	var btn_node = get_node("Border/Bg/Main/Sides/Data/Button")
	if(item_state == "HOVER"):
		mouse_node = temp_mouse_node
		item_state = "FIXED"
		mouse_node.get_node("Background/ItemBg").texture = index_bg
		btn_node.get_child(0).text = shop_setting + " Item"
		if(shop_setting == "Buy"):
			if(!compare_price()):
				btn_node.hide()
				return
		btn_node.show()

	elif(mouse_node != temp_mouse_node):
		mouse_node.get_node("Background/ItemBg").texture = null
		mouse_node = temp_mouse_node

	else:
		item_state = "HOVER"
		price_value.text = EMPTY
		btn_node.hide()
		mouse_node = null

# Checks if the user can afford the item
func compare_price():
	var index = int(mouse_node.name)%100
	var coins_val = DataResource.dict_item_masterlist[DataResource.dict_item_shop["Item" + str(index)]].ItemValue
	if(coins_val > DataResource.temp_dict_player["coins"]):
		return false
	return true

# Reduces qty of item by 1
func sell_item():
	var element_index = str(int(mouse_node.name)%100)
	var sell_coins = DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_value/2
	DataResource.change_coins(sell_coins)
	coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])
	DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty -= 1

	# Item Stock is empty: Update node containing item
	if (DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty != 0):
		mouse_node.get_node("Background/ItemBg/ItemBtn/Qty").text = str(DataResource.dict_inventory[active_tab.name]["Item" + element_index].item_qty)

	# Item Stock is empty:
	else:
		var dict_size = DataResource.dict_inventory[active_tab.name].size()
		# Dequip item held if that node is a held item
		if(active_tab.name == "Weapons" || active_tab.name == "Apparel"):
			if(DataResource.temp_dict_player[active_tab.name + "_item"] == mouse_node.name):
					inventory.item_status(inventory.find_node(mouse_node.name, true, false), "DEQUIP")

		# From deleted item's index upwards, shift affected indexes down by 1
		element_index = int(element_index)
		for _i in range(element_index, dict_size):
			#loaddata
			DataResource.dict_inventory[active_tab.name]["Item" + str(element_index)] = DataResource.dict_inventory[active_tab.name]["Item" + str(element_index + 1)]
			var updating_node_index = str(int(mouse_node.name)/100 * 100 + element_index)
			var updating_node = items_sell.get_node(active_tab.name).find_node(updating_node_index, true, false)
			var list_tab = DataResource.dict_inventory.get(active_tab.name)
			generate_specific_data(updating_node, element_index, list_tab)

			element_index += 1

		# Clear the last entry of dict and disable/clear its last node
		DataResource.dict_inventory[active_tab.name].erase("Item" + str(element_index))
		var deletion = str(int(mouse_node.name)/100 * 100 + element_index)
		var emptied_node = items_sell.get_node(active_tab.name).find_node(deletion, true, false)
		check_fixed()
		disable_mouse(emptied_node)

		get_node("Border/Bg/Main/Sides/Data/Button").hide()

	transaction_music.play()

# Increases qty of item by 1
func buy_item():
	# contains item type, item name and quantity
	var index = int(mouse_node.name)%100
	var coins_val = DataResource.dict_item_masterlist[DataResource.dict_item_shop["Item" + str(index)]].ItemValue
	if(coins_val > DataResource.temp_dict_player["coins"]):
		return
	var item_data = []
	#Append item to inventory
	var current_tab_name = DataResource.dict_item_masterlist[DataResource.dict_item_shop["Item" + str(index)]].ItemType
	item_data.append(current_tab_name)
	item_data.append(DataResource.dict_item_shop["Item" + str(index)])
	item_data.append(1)
	SceneControl.loot_dict[1] = item_data
	SceneControl.append_loot(1)

	# Update coins val and item qty
	DataResource.change_coins(-coins_val)
	coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])

	var dict_size = DataResource.dict_inventory[current_tab_name].size()
	var element_index = 1
	var node_multiplier
	match current_tab_name:
		"Weapons": node_multiplier = WEAPONS
		"Apparel": node_multiplier = APPAREL
		"Consum": node_multiplier = CONSUM
		"Misc": node_multiplier = MISC

	# Update item_data of all items in tab of updated item, enable mouse for new node if created
	for _i in range(1, dict_size + 1):
			#loaddata
			var updating_node_index = node_multiplier + element_index
			var updating_node = items_sell.get_node(current_tab_name).find_node(str(updating_node_index), true, false)
			var list_tab = DataResource.dict_inventory.get(current_tab_name)
			enable_mouse(updating_node)
			generate_specific_data(updating_node, element_index, list_tab)

	transaction_music.play()
	
# Sells/Buys Item
func _on_Button_pressed():
	match shop_setting:
		"Sell": sell_item()
		"Buy": buy_item()

# Based on whether the shop is active
func _on_Shop_visibility_changed():
	if(!visible):
		check_fixed()
		var shop_sell = get_parent().find_node("Items", true, false)
		update_tab_items(WEAPONS, shop_sell, "Weapons")
		update_tab_items(APPAREL, shop_sell, "Apparel")
		update_tab_items(CONSUM, shop_sell, "Consum")
		update_tab_items(MISC, shop_sell, "Misc")
	else:
		coins.get_node("CoinsVal").text = str(DataResource.temp_dict_player["coins"])

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
			if(!updating_node.is_connected("mouse_entered", inventory, "_on_mouse_entered")):
				inventory.enable_mouse(updating_node, true)
			element_index += 1
		if(element_index == dict_size):
			updating_node_index = str(int(tab_constant + element_index))
			updating_node = updating_path.get_node(tab_name).find_node(updating_node_index, true, false)
			if(updating_node.get_child(0).get_child(0).name != "ItemName"):
				inventory.disable_mouse(updating_node)

func handle_input(event):
	if is_active_gui:
		if Input.is_action_just_pressed("escape"):
			_on_Exit_pressed()
		elif Input.is_action_just_pressed("shop_buy"):
			_on_Buy_pressed()
		elif Input.is_action_just_pressed("shop_sell"):
			_on_Sell_pressed()

func _on_Exit_pressed():
	free_the_shop()

func free_the_shop():
	DataResource.save_rest()
	emit_signal("release_gui", "shop")
