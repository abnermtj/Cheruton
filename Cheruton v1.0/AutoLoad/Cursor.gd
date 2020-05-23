extends Node

# Load the custom images for the mouse cursor.
var arrow = preload("res://Display/MouseDesign/arrow.png")
var beam = preload("res://Display/MouseDesign/beam.png")

# Changing cursor: 	set_default_cursor_shape(int btw 0 & 15)

func init_cursor():
	
	# Changes the shapes of the cursor for various functions.
	Input.set_custom_mouse_cursor(arrow)
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)
	


