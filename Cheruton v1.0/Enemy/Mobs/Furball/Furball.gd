extends Enemy

const GRAVITY = 2200
const TERMINAL_VELOCITY = 5000
const MAX_X_VEL = 300

export (bool) var start_flipped := false

onready var body_rot = $bodyPivot/bodyRotate
onready var body_pivot = $bodyPivot
onready var hit_box = $hitBox
onready var alert_area = $alertArea
onready var attack_area = $attackRangeArea

onready var initial_pos = global_position
onready var dust = preload("res://Effects/Dust/JumpDust/jumpDust.tscn")

var look_dir = Vector2(1,0) setget set_look_direction

var return_to_sleep = false
var damage : int
var hitter : Node
var hitter_pos : Vector2

func _ready():
	$bodyPivot/bodyRotate/hurtBox.obj = self

	health = 15
	health_bar.init_bar(health)

	if start_flipped:
		look_dir = Vector2(-1,0)
		body_pivot.scale = Vector2(-1, 1)

func set_look_direction(dir : Vector2):
	if dir != Vector2() :look_dir = dir

	if dir.x in [-1, 1]:
		body_pivot.scale = Vector2(dir.x,1)

func move():
	velocity = move_and_slide(velocity, Vector2.UP)

# AREAS
func _on_hitBox_area_entered(area):
	damage = area.damage
	hitter = area.obj

	hitter_pos = hitter.global_position
	if states.current_state.name != "dead":
		change_state("hit")

func _on_alertArea_body_exited(body):
	return_to_sleep = true

func _on_alertArea_body_entered(body):
	return_to_sleep = false

func play_hit_effect():
	var instance = hit_effect.instance()
	instance.global_position = global_position
	get_parent().add_child(instance)
