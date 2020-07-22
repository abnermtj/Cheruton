extends Node2D

func _ready():
	hide()

func play_anim(name):
	$Timer.start(3.2)
	show()
	$AnimationPlayer.play(name)



func _on_Timer_timeout():
	$houseSmoke.emitting = false
