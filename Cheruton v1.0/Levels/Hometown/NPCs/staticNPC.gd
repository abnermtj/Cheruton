extends Node2D

class_name StaticNPC

func _ready():
	$AnimationPlayer.play("idle")
	connect("body_entered", self, "player_enter")
	connect("body_exited", self, "player_exited")

func player_enter(body):
	$Sprite.material.set_shader_param("width", .5)
func player_exited(body):
	$Sprite.material.set_shader_param("width", 0)
