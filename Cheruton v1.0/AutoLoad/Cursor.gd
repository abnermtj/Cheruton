extends Node

var arrow = preload("res://Display/MouseDesign/arrow.png")
var beam = preload("res://Display/MouseDesign/beam.png")

func init_cursor():
	Input.set_custom_mouse_cursor(arrow)
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)



