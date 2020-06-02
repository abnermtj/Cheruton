extends StaticBody2D

const ENTERED = 0
const EXITED = 1

signal grapple_command # int enter/exit indication and Vec2 for position

func _ready():
	$circleIndicator.visible = false

func _on_grappleArea_body_entered(body):
	if body.name == "player":
		$circleIndicator.visible = true
		emit_signal("grapple_command", ENTERED, global_position)


func _on_grappleArea_body_exited(body):
	if body.name == "player":
		$circleIndicator.visible = false
		emit_signal("grapple_command", EXITED,Vector2())

func _process(delta):
	var angle = get_viewport().get_mouse_position().angle_to_point(Vector2(200,200))

