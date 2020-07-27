extends Level

func _ready():

#	player_spawn_pos = Vector2(525, 98)
	player_spawn_pos = Vector2(10525, 98)

	story_file = "res://Levels/Hometown/Stories/Baked/HometownDialog.tres"
	SceneControl.change_story(story_file) # delete next time thisis to directly run it

	$Buildings.add_to_group("one_way_platforms")
	$Props.add_to_group("one_way_platforms")
	$player.set_input_enabled(true)

#func _input(event):
#	if Input.is_action_just_pressed("reset"):
#		$player.velocity = Vector2()
#		$player.position = player_spawn_pos

func handle_death_zone(body):
	$player.velocity = Vector2()
	$player.position = player_spawn_pos


# triggers the cutscene to teleport, area only masks for the player layer
func _on_Area2D_body_entered(body):
	$CutscenePlayer.play("cutscene0_0")
