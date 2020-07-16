extends RigidBody2D

const LIFE_TIME = 3.5

func _ready():
	$Timer.start(LIFE_TIME)

func _on_Timer_timeout():
	queue_free()

func _process(delta):
	modulate = Color(1,1,1, $Timer.time_left/LIFE_TIME)
