extends Enemy

const GRAVITY = 2200
const TERMINAL_VELOCITY = 5000
const MAX_X_VEL = 300

export (bool) var start_flipped := false

onready var animation_player = $AnimationPlayer
onready var animation_player_fx = $AnimationPlayerFx
onready var body_rot = $bodyPivot/bodyRotate
onready var body_pivot = $bodyPivot
onready var hit_box = $hitBox
onready var alert_area = $alertArea
onready var attack_area = $attackRangeArea
onready var states = $states
onready var health_bar = $HealthBar
onready var level = get_parent().get_parent()
onready var player = level.get_node("player")
onready var initial_pos = global_position
onready var dust = preload("res://Effects/Dust/JumpDust/jumpDust.tscn")

var velocity = Vector2()
var health = 15.0 setget set_health
var look_dir = Vector2(1,0) setget set_look_direction

var return_to_sleep = false
var damage : int
var hitter : Node
var hitter_pos : Vector2

func _ready():
	$bodyPivot/bodyRotate/hurtBox.obj = self
	health_bar.init_bar(health)

	if start_flipped:
		look_dir = Vector2(-1,0)
		body_pivot.scale = Vector2(-1, 1)

# HELPER FUNCTIONS
func set_look_direction(dir : Vector2):
	if dir != Vector2() :look_dir = dir

	if dir.x in [-1, 1]:
		body_pivot.scale = Vector2(dir.x,1)
func move():
	velocity = move_and_slide(velocity, Vector2.UP)

func set_health(val):
	health = val

	health_bar.animate_healthbar(val)
	if health <= 0.1:
		change_state("dead")

# ANIMATION
func play_anim(string):
	if animation_player:
		animation_player.clear_queue()
		animation_player.play(string)
		animation_player.advance(0) # play from the start of anim
func queue_anim(string):
	if animation_player:
			animation_player.queue(string)
func play_anim_fx(string):
	if animation_player_fx: animation_player_fx.play(string)
func queue_anim_fx(string):
	if animation_player_fx: animation_player_fx.queue(string)


# DEBUG
func _process(delta):
	$Label.text = str(states.current_state.name)

# AREAS
func _on_hitBox_area_entered(area):
	damage = area.damage
	hitter = area.obj

	hitter_pos = hitter.global_position
	if states.current_state.name != "dead":
		change_state("hit")

# CAMERA
func shake_camera(dur, freq, amp, dir):
	level.shake_camera(dur, freq, amp, dir)

func _on_alertArea_body_exited(body):
	return_to_sleep = true

func _on_alertArea_body_entered(body):
	return_to_sleep = false

func play_hit_effect():
	var instance = hit_effect.instance()
	instance.global_position = global_position
	get_parent().add_child(instance)

func change_state(state_name : String):
	states._change_state(state_name)
