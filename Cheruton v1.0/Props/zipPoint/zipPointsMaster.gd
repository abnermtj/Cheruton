# This function manages and controls the grapple points, indicating to the player what the closest grapple point is
extends Node2D

const ENTERED = 0
const EXITED = 1

var num_areas_inside = 0

signal grapple_command_final # int enter/exit indication and Vec2 for position

func _ready():
	for child in get_children():
		child.connect("grapple_command", self, "grapple_command_handler")

# handles when you enter new an area before you leave the current one
func grapple_command_handler(command, center):
	if command == ENTERED:
		num_areas_inside += 1
		emit_signal("grapple_command_final", command, center)
	elif command == EXITED:
		num_areas_inside -= 1
		if num_areas_inside == 0: # not in a grapple area, accounts for when u enter an area before u left the previous one
			emit_signal("grapple_command_final", command, center)



