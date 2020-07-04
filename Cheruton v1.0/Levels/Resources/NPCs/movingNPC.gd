extends KinematicBody2D

class_name MovingNPC

var DIR_CHANGE_TIME = 8

export var walk_speed : int = 110 # remember to move ray case if walk speed is ever too much

onready var body_rotate = $bodyRotate

var dir
var timer

func _ready():
	dir = -1
	body_rotate.scale.x = -1
	timer = DIR_CHANGE_TIME # remember to set this when overwriting dir change time in virtual funcs
	$AnimationPlayer.play("walk")
	$playerDetectionArea.connect("body_entered", self, "player_entered")
	$playerDetectionArea.connect("body_exited", self, "player_exited")
	add_to_group("NPCs")

func _physics_process(delta):
	timer -= delta
	if timer < 0 :
		timer = DIR_CHANGE_TIME
		flip_dir()

	move_and_slide(Vector2(dir*walk_speed, 100))

	if dir == -1 and not $rayLeft.is_colliding():
		flip_dir()
	elif dir == 1 and not $rayRight.is_colliding():
		flip_dir()

func flip_dir():
	dir = -dir
	body_rotate.scale.x = -body_rotate.scale.x

func player_entered(body):
	$bodyRotate/Sprite.material.set_shader_param("width", .5)
func player_exited(body):
	$bodyRotate/Sprite.material.set_shader_param("width", 0)

