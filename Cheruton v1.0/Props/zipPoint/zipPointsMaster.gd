# This function manages and controls the zip points, indicating to the player what the closest zip point is

extends Node2D

const ENTERED = 0
const EXITED = 1

signal zip_command_final # int enter/exit indication and Vec2 for position

func _ready():
	for child in get_children():
		child.connect("zip_command", self, "zip_command_handler")

# currently only relays the command, but this configuration always for future managing of zip points
func zip_command_handler(command, center):
	emit_signal("zip_command_final", command, center)


