extends Level

func _ready():
	camera.current = true
	bg_music_file = "res://Music/Background/Relax.mp3"
	$CutscenePlayer.play("day")
	player_spawn_pos = Vector2(525, -208)
#	player_spawn_pos = Vector2(10525, -208)
#	player_spawn_pos = Vector2(5000, -208)
	story_file = "res://Levels/Hometown/Stories/Baked/HometownDialog.tres"

	

	$player.set_isInputEnabled(true)

#func _input(event):
#	if Input.is_action_just_pressed("reset"):
#		$player.velocity = Vector2()
#		$player.position = player_spawn_pos

func handle_death_zone(body):
	$player.velocity = Vector2()
	$player.position = player_spawn_pos


# triggers the cutscene to teleport
func _on_Area2D_body_entered(body):
	$CutscenePlayer.play("cutscene0_0")
	
func next_scene():
	SceneControl.change_scene(self, "res://Levels/Cave0/Cave0.tscn")
