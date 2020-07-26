extends basePopUp

#for debugging, allows the scene to run by itself
#func _ready():
#	if not DataResource.dict_settings:
#		if(!DataResource.loaded):
#			DataResource.load_data()

func handle_input(event):
	if is_active_gui:
		if Input.is_action_just_pressed("inventory"):
			emit_signal("new_gui", "inventory")
		elif Input.is_action_just_pressed("escape"):
			emit_signal("new_gui", "pause")
		elif Input.is_action_just_pressed("shop"):
			emit_signal("new_gui", "shop")
