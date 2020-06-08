extends KinematicBody2D
class_name Enemy



func _ready():
	call_deferred("_link_to_target_area")
	
func _link_to_target_area():
	var node = find_node("target_area")
	if(!node):
		return
#func _highlight_target():
#	pass
#
#func _clear_target():
#	pass
