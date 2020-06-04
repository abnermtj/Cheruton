extends Control

class_name baseGui

var is_active_gui = false setget set_is_active_gui

signal new_gui
signal release_gui

func handle_input(event):
	pass

func set_is_active_gui(val):
	is_active_gui = val
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
