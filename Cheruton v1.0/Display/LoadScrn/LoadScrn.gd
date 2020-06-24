extends Control

onready var progress = $ColorRect/CenterContainer/VBoxContainer/LoadProg

func _on_LoadScrn_visibility_changed():
	if(!self.visible):
		progress.value = 0
		
