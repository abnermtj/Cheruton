extends Enemy

const GRAVITY = 2200
const TERMINAL_VELOCITY = 5000
const MAX_X_VEL = 300

export (bool) var start_flipped := false
export (bool) var patrolling := false
export (float) var patrol_range_x

onready var body_rot = $bodyPivot/bodyRotate
onready var body_pivot = $bodyPivot
onready var hit_box = $hitBox
onready var attack_area = $attackRangeArea

onready var initial_pos = global_position
onready var dust = preload("res://Effects/Dust/JumpDust/jumpDust.tscn")

var look_dir = Vector2(1,0) setget set_look_direction
var flip_patrol_end = 1
var return_to_default = false
var damage : int
var hitter : Node
var hitter_pos : Vector2

func _ready():
	health = 15
	health_bar.init_bar(health)

	if start_flipped:
		look_dir = Vector2(-1,0)
		body_pivot.scale = Vector2(-1, 1)
	if patrolling:
		change_state("jump")

	$bodyPivot/bodyRotate/hurtBox.obj = self

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

func _on_alertArea_body_entered(body):
	return_to_default = false

# FIX ME: Move some of this code specific to hit FX directly else gonna rewrite a lot
func play_hit_effect():
	var instance = hit_effect.instance()
	instance.global_position = global_position

	var player_waist_pos = player.global_position + Vector2 (0, 30)
	var player_angle_to_mob = Vector2.UP.angle_to(global_position - player_waist_pos)
	instance.rotation = player_angle_to_mob - PI/2
#
	var gravity = Vector3()
	gravity.x =  -2900 * sin(player_angle_to_mob)
	gravity.y = clamp (abs(3000 * cos(player_angle_to_mob)), 1300, 3000)

	instance.get_node("Particles2D").process_material.gravity = gravity

	level.add_child(instance)
	move_child(instance, 0) # appears behind mobs and player

func _on_followArea_body_exited(body):
	return_to_default = true
