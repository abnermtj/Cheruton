extends Node2D


onready var player = get_parent().get_node("player")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Area2D_body_entered(body):
	if(body == player):
		$Player.play("Activate")
		print(true)


func _on_Area2D_body_exited(body):
	if(body == player):
		$Player.play("Deactivate")
