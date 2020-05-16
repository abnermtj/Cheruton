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
	for i in range(0, list_tab.size()):
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


func _on_mouse_entered(node):
	if(item_state == "FREE"):
		var element_index = int(node.name)
		node.get_child(0).texture = index_bg
		var insp = retrieve_path_insp()
		insp.get_node("ItemInsp2").show()
		insp.get_node("Buttons").show()

# Mouse leaves label section of the element
func _on_mouse_exited(node):
	if(item_state == "FREE"):
		node.get_child(0).texture = null
		var insp = retrieve_path_insp()
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
	print("OK")
	match item_state:
		"FREE":
			item_state = "FIXED"
			fixed_node = node
		"FIXED": 
			if (node != fixed_node):
				fixed_node.get_child(0).texture = null
				fixed_node = node
			else:
				item_state = "FREE"
	if(item_state == "FIXED"): # Highlight the button last pressed
		node.get_child(0).texture = index_bg




func item_inspector_default():
	#show stats of current item - only for weapon/apparel
	#show description of current item - rest
	pass

func item_inspector_new():
	var insp = "BorderBackground/InnerBackground/VBoxContainer/MElements/InspWeapons/ItemInsp2"
	get_node(insp).visible = !get_node(insp).is_visible()
	pass
