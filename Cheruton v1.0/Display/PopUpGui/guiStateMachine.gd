extends Node2D

var statesDict = {}
var pop_up_enable_list = {}
var active = true
var state_name_stack = []
var dialog_over:= false

func _ready():
	for child in get_children():
		child.connect("new_gui", self, "new_gui")
		child.connect("release_gui", self, "release_gui")
		statesDict[child.name] = child

	for state in statesDict:
		pop_up_enable_list[state] = true
	reset()

func reset():
	state_name_stack.resize(0)
	state_name_stack.append("empty")
	for child in get_children():
		child.hide()
		child.isisActive_gui = false
	statesDict[state_name_stack[0]].isisActive_gui = true

func _input(event):
	if active and state_name_stack:
		statesDict[state_name_stack[-1]].handle_input(event)

func new_gui(gui_name):
	if active == false:
		return

	if not pop_up_enable_list[gui_name] : return

	if state_name_stack.has(gui_name): return
	statesDict[gui_name].begin()
	state_name_stack.push_back(gui_name)

	for child in get_children():
		child.isisActive_gui = false
	statesDict[gui_name].isisActive_gui = true
	on_gui_changed()

func release_gui(gui_name):
	if (gui_name == "dialog"):
		dialog_over = true

	if active == false:
		return

	statesDict[gui_name].end()
	statesDict[gui_name].isisActive_gui = false
	state_name_stack.pop_back()
	statesDict[state_name_stack[-1]].isisActive_gui = true
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
