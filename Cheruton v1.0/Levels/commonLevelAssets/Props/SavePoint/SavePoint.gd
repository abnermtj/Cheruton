extends Area2D

var level

func _ready():
	add_to_group("needs_level_ref")

func _on_SavePoint_body_entered(body):
	save()

func save():
	level.player_spawn_pos = global_position

	$rotate.scale.x = scale.x # so that the text pop up doesn't flip along with the sprite
	$AnimationPlayer.play("saved")
