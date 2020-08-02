extends Node2D

class_name StaticNPC

export var is_flipped = false


onready var sprite = $Sprite
onready var sprite2 = $Sprite2
onready var dialog_name = name

var level
var player

var interact_enabled = true setget set_interact_enabled

var interaction_type

var is_talking = false
var save_dir : int

func _ready():
	interaction_type = "dialog"
	$AnimationPlayer.play("idle")
	add_to_group("interactibles", true)
	add_to_group("NPCs", true)

	add_to_group("needs_player_ref", true)
	add_to_group("needs_level_ref", true)

	set_process(false)
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
		if sprite2: sprite2.scale.x = save_dir

func interact(body):
	is_talking = true
	SceneControl.change_and_start_dialog(dialog_name)
	DataResource.temp_dict_player.dialog_complete = false # the defered call in Scene Control causes timing issue
	save_dir = sprite.scale.x
	sprite.scale.x = sign(body.global_position.x - global_position.x) * (-1 if is_flipped else 1)
	if sprite2: sprite2.scale.x = sprite.scale.x
	set_process(true)

func set_interact_enabled(val):
	interact_enabled = val

func set_dialog_name(val : String):
	dialog_name = val

func set_outline_enabled(val):
	sprite.visible = val
