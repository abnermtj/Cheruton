extends Node2D

onready var anim_player = $AnimationPlayer

func play_anim(name):
	anim_player.clear_queue()
	anim_player.play(name)
	anim_player.advance(0)
