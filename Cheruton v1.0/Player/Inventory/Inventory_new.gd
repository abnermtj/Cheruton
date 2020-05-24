extends Control

var active_tab

signal tab_changed(next_tab)

onready var active_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg_keypress.png")
onready var default_tab_image = preload("res://Player/Inventory/Icons/Button_Bg/inventory_bg.png")

onready var tabs = $Border/Bg/Contents/Tabs
onready var equipped_coins = $Border/Bg/Contents/EquippedCoins

func _ready():
	connect_tabs()
	emit_signal("tab_changed", "Weapons")
	

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
		"Key Items": change_active_tab(tabs.get_node("KeyItems/KeyItems"))

	if(next_tab):
		print("Current Tab: ")
		print(next_tab)

func change_active_tab(new_tab):
	# Set current tab to default colour and hide its items
	if(active_tab):
		active_tab.set_normal_texture(default_tab_image)

	# Set new active tab and its colour and show its items
	active_tab = new_tab

	active_tab.set_normal_texture(active_tab_image)
