extends Node2D

class_name StaticNPC

export var is_flipped = false

onready var sprite = $Sprite

var interaction_type
var is_talking = false
var save_dir : int

func _ready():
	interaction_type = "dialog"
	$AnimationPlayer.play("idle")
	add_to_group("interactibles")
	add_to_group("NPCs")

	if is_flipped: scale.x = -abs(scale.x)


func pend_interact():
	sprite.material.set_shader_param("width", .5)

func unpend_interact():
	sprite.material.set_shader_param("width", 0)

func _process(delta):
	if is_talking and DataResource.temp_dict_player.dialog_complete:
		is_talking = false
		set_process(false)
		sprite.scale.x = save_dir

func interact(body):
	is_talking = true
	SceneControl.change_and_start_dialog(name)
	save_dir = sprite.scale.x
	sprite.scale.x = sign(body.global_position.x - global_position.x) * (-1 if is_flipped else 1)
	set_process(true)

