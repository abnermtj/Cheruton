extends Level

onready var save_position = $player.position
onready var cut_scene_player = $CutScenePlayer

var cur_cut_scene_completed = false
var flying_sword

func _ready():
	camera.current = true
	bg_music_file = "res://Music/Background/Relax.mp3"
	story_file = "res://Levels/Grasslands2/Stories/Baked/Grasslands2Dialog.tres"
	entrace_to_pos_dict = {0: Vector2(-404, 252)}

	if not enter_point: enter_point = 0 # default must be set for all scenes

	player_spawn_pos = entrace_to_pos_dict[enter_point] # enter point set by scene control

	#debug
#	player_spawn_pos = Vector2(0)
	$player.set_isInputEnabled(true)
#	cur_cut_scene_completed = false
#	cutscene_number = 0 # cutscene
#	cutscene_index = 0 #
	########
#	cur_cut_scene_completed = DataResource.dict_player.completed_cutscenes["grasslands2_0"]
	if not cur_cut_scene_completed:
		cutscene_number = 0 # cutscene
		cutscene_index = 0 # specific part of cutscene (separated by dialog etc)
		next_cutscene()
	SceneControl.fade_in_scene()

func next_cutscene():
#	print(cutscene_number, cutscene_index)
	cur_cut_scene_completed = false
	cut_scene_player.play("cutscene" + str(cutscene_number)+ "_" + str(cutscene_index))

	match cutscene_number:
		0:
			if cutscene_index == 3:
#				DataResource.dict_player.completed_cutscenes["grasslands0_0"] = true # will no longer be played on reenter
				end_cutscene()
				return
	cutscene_index += 1

func end_cutscene():
	cur_cut_scene_completed = true
	end_cutscene_mode()
	cutscene_number += 1
	cutscene_index = 0

func _process(delta):
	if wait_dialog_complete and DataResource.temp_dict_player.dialog_complete:
		next_cutscene()
		wait_dialog_complete = false

func turn_npc_player():
	$NPCs/moneygirl.face_player(player.global_position)
#
#func _input(event):
#	if Input.is_action_just_pressed("reset"):
#		next_scene()
#
#		var mob = preload("res://Enemy/Mobs/Furball/Furball.tscn")
#		var instance = mob.instance()
#		instance.position = save_position
#		$Mobs.add_child(instance)

#	if Input.is_action_just_pressed("attack"):
#		shake_camera(.5,60,4, Vector2())
	pass

func on_player_dead():
	player.global_position = player_spawn_pos
	DataResource.change_health(999)

func handle_death_zone(body):
	player.velocity = Vector2()
	player.position = save_position

func play_cutscene_dialog(name : String):
	DataResource.temp_dict_player.dialog_complete = false
	SceneControl.change_and_start_dialog(name)
	wait_dialog_complete = true

func shake_camera(time : float, freq : float, power : float, dir: Vector2):
	camera.shake(time, freq, power, dir)

func next_scene():
	SceneControl.change_scene(self, "res://Levels/Hometown/Hometown.tscn")
