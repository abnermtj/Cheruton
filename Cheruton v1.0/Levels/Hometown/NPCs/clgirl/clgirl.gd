extends StaticNPC

func interact(body):
	SceneControl.change_and_start_dialog(name) # else his anvil will also rotate
