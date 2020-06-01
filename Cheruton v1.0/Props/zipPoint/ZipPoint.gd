extends StaticBody2D

const ENTERED = 0
const EXITED = 1

signal zip_command # int enter/exit indication and Vec2 for position

func _ready():
	$circleIndicator.visible = false

func _on_zipArea_body_entered(body):
	if body.name == "player":
		$circleIndicator.visible = true
		emit_signal("zip_command", ENTERED, global_position)


func _on_zipArea_body_exited(body):
	if body.name == "player":
		$circleIndicator.visible = false
		emit_signal("zip_command", EXITED,Vector2())

