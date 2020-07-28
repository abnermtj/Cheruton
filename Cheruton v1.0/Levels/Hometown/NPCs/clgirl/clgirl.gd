extends StaticNPC

func _ready():
	var _connect_0 = DataResource.connect("dialog_over", self, "_on_dialog_processed")

func interact(body):
	SceneControl.change_and_start_dialog(name) # else his anvil will also rotate

func _on_dialog_processed():
	emit_signal("new_gui", "shop")
