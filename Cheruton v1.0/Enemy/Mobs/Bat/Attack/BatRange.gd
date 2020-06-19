extends KinematicBody2D

const SPEED = 600

onready var player = get_parent().get_parent().get_node("player")

var velocity = Vector2()


func _ready():
	velocity = global_position.direction_to(player.global_position)
	velocity *= SPEED
	print(velocity)

func _process(delta):
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN * 8, Vector2.UP)

func _on_HitBox_body_entered(body):
	print("QueuedFree")
	self.queue_free()
