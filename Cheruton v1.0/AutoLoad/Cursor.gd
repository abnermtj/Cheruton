extends Node

# Load the custom images for the mouse cursor.
var arrow = preload("res://Display/MouseDesign/arrow.png")
var beam = preload("res://Display/MouseDesign/beam.png")


func init_default_cursor():
	
	# Changes only the shapes of the cursor.
	Input.set_custom_mouse_cursor(arrow)
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)

func set_cursor(cursor_type):
	Input.set_default_cursor_shape(Input.CURSOR_IBEAM)
