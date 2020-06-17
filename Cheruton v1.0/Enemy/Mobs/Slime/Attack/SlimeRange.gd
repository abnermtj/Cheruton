extends KinematicBody2D

var velocity = Vector2()
var speed = 200

onready var attack_node = get_parent().get_node(self.name)


func _ready():
	velocity.y = 0

func _process(delta):
	if(velocity.x != 0):
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN * 8, Vector2.UP)

func _on_HitBox_body_entered(body):
	attack_node.queue_free()

