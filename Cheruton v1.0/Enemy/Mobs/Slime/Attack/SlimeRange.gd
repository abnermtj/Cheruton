extends KinematicBody2D

const SPEED = 400

var velocity = Vector2()


func _ready():
	velocity.y = 0
	velocity.x = get_parent().dir_curr * SPEED

func _process(delta):
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN * 8, Vector2.UP)

func _on_HitBox_body_entered(body):
	self.queue_free()

