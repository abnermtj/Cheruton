extends Node2D

onready var value = $Value
onready var tween = $Tween

var amount = 0
var text_velocity = Vector2()

func _ready():
	value.set_text(str(abs(amount)))

	var angle = rand_range(-40, 40)
	text_velocity = Vector2(angle, -100)
	tween.interpolate_property(self, "scale", scale, Vector2(0.30, 0.30), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "scale", Vector2(0.3, 0.3), Vector2(0.1, 0.1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3)
	tween.start()

func _on_Tween_tween_all_completed():
	queue_free()

func _physics_process(delta):
	global_position += text_velocity * delta
