extends KinematicBody2D

class_name MovingNPC

var DIR_CHANGE_TIME = 8

export var walk_speed : int = 110 # remember to move ray case if walk speed is ever too much

onready var body_rotate = $bodyRotate

var interaction_type
var dir
var timer

func _ready():
	dir = -1
	body_rotate.scale.x = -1
	timer = DIR_CHANGE_TIME # remember to set this when overwriting dir change time in virtual funcs
	$AnimationPlayer.play("walk")
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

func flip_dir():
	dir = -dir
	body_rotate.scale.x = -body_rotate.scale.x

func pend_interact():
	$bodyRotate/Sprite.material.set_shader_param("width", .5)
func unpend_interact():
	$bodyRotate/Sprite.material.set_shader_param("width", 0)
func interact():
	SceneControl.change_and_start_dialog(name)

