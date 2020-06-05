extends Node2D

var states_map
var active = true
var state_name_stack = []

func _ready():
	for child in get_children():
		child.connect("new_gui", self, "new_gui")
		child.connect("release_gui", self, "release_gui")

	states_map = {
		"emptygui": $emptygui,
		"inventory": $inventory,
		"pause": $pause,
		"settings": $settings,
		"shop": $shop
	}

	soft_reset()


func soft_reset():
	state_name_stack.resize(0)
	state_name_stack.append("emptygui")
	for child in get_children():
		child.visible = false
		child.is_active_gui = false
	states_map[state_name_stack[0]].is_active_gui = true

func new_gui(gui_name):
	if active == false:
		return

	states_map[gui_name].visible = true
	state_name_stack.push_back(gui_name)
	for child in get_children():
		child.is_active_gui = false
	states_map[gui_name].is_active_gui = true

func release_gui(gui_name):
	if active == false:
		return

	states_map[gui_name].visible = false
	states_map[gui_name].is_active_gui = false
	state_name_stack.pop_back()
	states_map[state_name_stack[-1]].is_active_gui = true

func _input(event):
	if active and state_name_stack:
		states_map[state_name_stack[-1]].handle_input(event)

func _physics_process(delta):
	if active:
		if state_name_stack.has("pause"):
			get_tree().paused = true
		else:
			get_tree().paused = false

