extends KinematicBody2D

var velocity = Vector2()
var speed = 200
var attack_name


func _ready():
	velocity.y = 0
	velocity.x = self.get_parent().dir_curr * speed
	attack_name = self.name

