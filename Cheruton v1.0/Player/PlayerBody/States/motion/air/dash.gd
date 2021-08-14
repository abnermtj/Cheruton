extends airState

const INITIAL_SPEED = 5000
const MIN_SPEED = 200
const OFFSET_FROM_SWORD_POS = 72
const INITIAL_STAGE_TIME = .1

enum stages{INITIAL = 1, MID_DASH = 2, END =3 }

onready var color_shader = preload("res://Effects/SolidColor/pink.tres")

var stage : int
var dir : Vector2
var goal_pos : Vector2
var timer : float
var save_player_mask

func handle_input(event): # overwrite to disables all inputs
	pass

func enter():
	var normal = owner.sword_col_normal
	owner.look_direction = -normal
	goal_pos = owner.sword_pos + OFFSET_FROM_SWORD_POS * normal

	owner.play_anim("dash")
	owner.play_sound("dash")
	owner.play_sound("land_dirt_soft1")
	owner.timers.get_node("ghostTimer").start(.05)
	owner.body_pivot.material = color_shader
	stage = stages.INITIAL
	timer = INITIAL_STAGE_TIME
	save_player_mask = owner.collision_mask
	owner.collision_mask = 0

func update(delta):
	timer -= delta
	owner.look_direction = Vector2(sign((goal_pos - owner.global_position).x), 0)

	match stage:
		stages.INITIAL:
			owner.velocity *= .98
			if timer < 0 :
				owner.velocity =  (goal_pos - owner.global_position).normalized() * INITIAL_SPEED
				stage = stages.MID_DASH
				owner.emit_dust("dash")
	
		stages.MID_DASH:
			owner.velocity = (goal_pos - owner.global_position).normalized() * owner.velocity.length()
			if owner.velocity.length() > 500:
				owner.velocity *= .97

			var displacement = goal_pos - owner.global_position
			if displacement.length() < 100.0:
				owner.velocity = owner.velocity.normalized() * 800
				stage = stages.END

		stages.END:
			owner.play_anim("pull_weapon")
			owner.queue_anim("fall") # need to an queue anim else it won't trigger animation finished signal

	owner.move()

func _on_animation_finished(anim_name):
	if anim_name == "pull_weapon":
		emit_signal("changeState", "fall")

func exit():
	owner.timers.get_node("ghostTimer").stop()
	owner.body_pivot.material = null
	owner.collision_mask = save_player_mask
