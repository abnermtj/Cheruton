extends Node2D

const GRAVITY = 1000

onready var animation_player = $AnimationPlayer
onready var timer = $resetTimer
onready var body = $body

export var reset_time : float = 1.0

var velocity = Vector2()
var is_triggered = false
var initial_pos

func _ready():
	initial_pos = global_position
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += GRAVITY * delta

# called by player
func handle_collision(collision: KinematicCollision2D, collider : KinematicBody2D):
	print("hereasdasdaasdasds")
	if !is_triggered:
		is_triggered = true
		animation_player.play("obj_land")
		velocity = Vector2()

func _on_AnimationPlayer_animation_finished(anim_name):
	set_physics_process(true)
	timer.start(reset_time)


func _on_resetTimer_timeout():
	set_physics_process(false)
	yield(get_tree(), "physics_frame")
	var temp = body.collision_layer
	body.collision_layer = 0
	body.global_position = initial_pos
	yield(get_tree(), "physics_frame")
	body.collision_layer = temp
	is_triggered = false

