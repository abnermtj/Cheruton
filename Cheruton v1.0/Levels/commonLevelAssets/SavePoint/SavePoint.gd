extends Area2D

func _on_SavePoint_body_entered(body):
	save()

func save():
	$rotate.scale.x = scale.x # so that the text pop up doesn't flip along with the sprite
	var level = get_parent().get_parent()
	level.player_spawn_pos = global_position

	$AnimationPlayer.play("saved")
