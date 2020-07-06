extends Area2D

func pend_interact():
	$Sprite.material.set_shader_param("width", .5)

func unpend_interact():
	$Sprite.material.set_shader_param("width", 0)

func interact():
	SceneControl.change_and_start_dialog(name)

