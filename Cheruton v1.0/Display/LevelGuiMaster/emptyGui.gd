extends baseGui

func _ready():
	if not DataResource.dict_settings:
		DataResource.load_data() # for debugging, allows the scene to run by itself

func handle_input(event):
	if is_active_gui:
		if Input.is_action_just_pressed("inventory"):
			emit_signal("new_gui", "inventory")
		elif Input.is_action_just_pressed("escape"):
			emit_signal("new_gui", "pause")
		elif Input.is_action_just_pressed("ui_focus_next"):#stub
			emit_signal("new_gui", "shop")

