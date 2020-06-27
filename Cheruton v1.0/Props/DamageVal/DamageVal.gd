extends Node2D

onready var value = $Value
onready var tween = $Tween
var amount = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	value.set_text(str(amount))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
