extends Node2D

class_name StaticNPC

var interaction_type
func _ready():
	interaction_type = "dialog"
	$AnimationPlayer.play("idle")
	add_to_group("interactibles")
	add_to_group("NPCs")


func pend_interact():
	$Sprite.material.set_shader_param("width", .5)

func unpend_interact():
	$Sprite.material.set_shader_param("width", 0)

func interact():
	SceneControl.change_and_start_dialog(name)
