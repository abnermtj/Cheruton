extends Control

class_name basePopUp

var isisActive_gui = false setget set_isisActive_gui

signal new_gui
signal release_gui

func begin():
	show()
func end():
	hide()

func handle_input(event):
	pass

func set_isisActive_gui(val):
	isisActive_gui = val
	if val:
		enable_all_buttons(self)
	else:
		disable_all_buttons(self)

func disable_all_buttons(node):
	for child in node.get_children():
		if child is Button or child is TextureButton: child.disabled = true
		if child.get_child_count() > 0:
			disable_all_buttons(child)

func enable_all_buttons(node):
	for child in node.get_children():
		if child is Button or child is TextureButton: child.disabled = false
		if child.get_child_count() > 0:
			enable_all_buttons(child)
