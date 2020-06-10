extends Node2D

const GRAVITY = 30

onready var animation_player = $AnimationPlayer
onready var timer = $resetTimer
onready var body = $body

export var reset_time : float = 1.0

var velocity = Vector2()
var is_triggered = false

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	body.position += velocity

# called by player
func handle_collision(collision: KinematicCollision2D, collider : KinematicBody2D):
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
	body.position = Vector2() # need to move while no collision else player follow return
	yield(get_tree(), "physics_frame")
	body.collision_layer = temp
	is_triggered = false

