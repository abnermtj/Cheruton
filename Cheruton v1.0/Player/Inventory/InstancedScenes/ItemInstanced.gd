extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal activate_item_insp

func _on_101_mouse_entered():
	print(self.name)
	emit_signal("activate_item_insp")


func _on_101_mouse_exited():
	emit_signal("activate_item_insp")
