extends Node2D

var states_map = {}
var pop_up_enable_list = {}
var active = true
var state_name_stack = []
var dialog_over:= false

func _ready():
	for child in get_children():
		child.connect("new_gui", self, "new_gui")
		child.connect("release_gui", self, "release_gui")
		states_map[child.name] = child

	for state in states_map:
		pop_up_enable_list[state] = true
	reset()

func reset():
	state_name_stack.resize(0)
	state_name_stack.append("empty")
	for child in get_children():
		child.hide()
		child.is_active_gui = false
	states_map[state_name_stack[0]].is_active_gui = true

func _input(event):
	if active and state_name_stack:
		states_map[state_name_stack[-1]].handle_input(event)

func new_gui(gui_name):
	if active == false:
		return

	if not pop_up_enable_list[gui_name] : return
	if state_name_stack.has(gui_name): return
	states_map[gui_name].begin()
	state_name_stack.push_back(gui_name)

	for child in get_children():
		child.is_active_gui = false
	states_map[gui_name].is_active_gui = true
	on_gui_changed()

func release_gui(gui_name):
	if (gui_name == "dialog"):
		dialog_over = true

	if active == false:
		return

	states_map[gui_name].end()
	states_map[gui_name].is_active_gui = false
	state_name_stack.pop_back()
	states_map[state_name_stack[-1]].is_active_gui = true
	on_gui_changed()

func on_gui_changed():
	if active:
		if state_name_stack.has("pause") || state_name_stack.has("inventory"):
			get_tree().paused = true
		else:
			if(dialog_over):
				DataResource.emit_signal("dialog_over")
				dialog_over = false
			get_tree().paused = false
