extends KinematicBody2D

class_name MovingNPC

var DIR_CHANGE_TIME = 8

export var walk_speed : int = 110 # remember to move ray case if walk speed is ever too much

onready var body_rotate = $bodyRotate
onready var anim_player = $AnimationPlayer
onready var dialog_name = name

var interaction_type : String
var dir : int
var timer : float
var is_talking = false
var save_dir : int

func _ready():
	dir = -1
	body_rotate.scale.x = -1
	timer = DIR_CHANGE_TIME # remember to set this when overwriting dir change time in virtual funcs
	anim_player.play("walk")
	interaction_type = "dialog"
	add_to_group("NPCs")
	add_to_group("interactibles")

func _physics_process(delta):
	timer -= delta
	if timer < 0 :
		timer = DIR_CHANGE_TIME
		flip_dir()

	move_and_slide(Vector2(dir*walk_speed, 100), Vector2.UP)

	if is_on_wall():
		flip_dir()
	elif dir == -1 and not $rayLeft.is_colliding():
		flip_dir()
	elif dir == 1 and not $rayRight.is_colliding():
		flip_dir()

func _process(delta):
	if is_talking and DataResource.temp_dict_player.dialog_complete:
		is_talking = false
		anim_player.play("walk")
		set_physics_process(true)
		set_process(false)
		body_rotate.scale.x = save_dir

func flip_dir():
	dir = -dir
	body_rotate.scale.x = -body_rotate.scale.x

func pend_interact():
	$bodyRotate/Sprite.material.set_shader_param("width", .5)
func unpend_interact():
	$bodyRotate/Sprite.material.set_shader_param("width", 0)

func interact(body):
	if is_talking: return
	SceneControl.change_and_start_dialog(dialog_name)
	DataResource.temp_dict_player.dialog_complete = false # the defered call in Scene Control causes timing issue
	is_talking = true
	anim_player.play("idle")
	set_physics_process(false)
	set_process(true)
	save_dir = body_rotate.scale.x
	body_rotate.scale.x = sign(body.global_position.x - global_position.x)



