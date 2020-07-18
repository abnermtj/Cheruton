extends Enemy

const GRAVITY = 2200
const TERMINAL_VELOCITY = 5000
const MAX_X_VEL = 300

onready var animation_player = $AnimationPlayer
onready var animation_player_fx = $AnimationPlayerFx
onready var body_rot = $bodyPivot/bodyRotate
onready var body_pivot = $bodyPivot
onready var hit_box = $hitBox
onready var alert_area = $alertArea
onready var attack_area = $attackRangeArea
onready var states = $states

onready var level = get_parent().get_parent()
onready var player = level.get_node("player")
onready var initial_pos = global_position

var velocity = Vector2()
var health = 100
var look_dir = Vector2(-1,0) setget set_look_direction

var return_to_sleep = false

# HELPER FUNCTIONS
func set_look_direction(dir : Vector2):
	if dir != Vector2() :look_dir = dir

	if dir.x in [-1, 1]:
		body_pivot.scale = Vector2(dir.x,1)
func move():
	velocity = move_and_slide(velocity, Vector2.UP)

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
	$Label.text = str(velocity)

# AREAS
func _on_hitBox_area_entered(area):
	health -= 10
	states._change_state("hit")

# CAMERA
func shake_camera(dur, freq, amp, dir):
	level.shake_camera(dur, freq, amp, dir)

# player left range
func _on_alertArea_body_exited(body):
	return_to_sleep = true

func _on_alertArea_body_entered(body):
	return_to_sleep = false
