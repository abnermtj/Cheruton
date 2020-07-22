extends Level

onready var save_position = $player.position
onready var cut_scene_player = $CutScenePlayer

var cur_cut_scene_completed = false
var wait_dialog_complete = false

func _ready():
	Engine.time_scale = 1.5
#	bg_music_file = "res://Sound/MusicDebug/Frantic-Gameplay.ogg"
	story_file = "res://Levels/Grasslands0/Stories/Baked/Grasslands0Dialog.tres"
	entrace_to_pos_dict = {0: Vector2(-200, 188),\
							1: Vector2(7866 ,2552)}
	if not enter_point: enter_point = 0 # default must be set for all scenes

	player_spawn_pos = entrace_to_pos_dict[enter_point] # enter point set by scene control

	#debug
	player_spawn_pos = Vector2(3028, -1936)
#	player_spawn_pos = Vector2(5472, 1056)
	cur_cut_scene_completed = true
	cutscene_number = 2 # cutscene
	cutscene_index = 0 #
	########
#	cur_cut_scene_completed = DataResource.dict_player.completed_cutscenes["grasslands0_0"]
	if not cur_cut_scene_completed:
		cutscene_number = 0 # cutscene
		cutscene_index = 0 # specific part of cutscene (separated by dialog etc)
		next_cutscene()

func next_cutscene():
	cur_cut_scene_completed = false
	cut_scene_player.play("cutscene" + str(cutscene_number)+ "_" + str(cutscene_index))

	match cutscene_number:
		0:
			if cutscene_index == 4:
#				DataResource.dict_player.completed_cutscenes["grasslands0_0"] = true # will no longer be played on reenter
				end_cutscene()
				return
		1:
			if cutscene_index == 1:
#				DataResource.dict_player.completed_cutscenes["grasslands0_1"] = true
				end_cutscene()
				return
		2:
			if cutscene_index == 1:
#				DataResource.dict_player.completed_cutscenes["grasslands0_2"] = true
				end_cutscene()
				return
		3:
			if cutscene_index == 3:
#				DataResource.dict_player.completed_cutscenes["grasslands0_2"] = true
				end_cutscene()
				return
		4:
			if cutscene_index == 3:
#				DataResource.dict_player.completed_cutscenes["grasslands0_3"] = true
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


func _input(event):
	if Input.is_action_just_pressed("reset"):
		player.velocity = Vector2()
		player.position = save_position

		var mob = preload("res://Enemy/Mobs/Furball/Furball.tscn")
		var instance = mob.instance()
		instance.position = save_position
		$Mobs.add_child(instance)
#	if Input.is_action_just_pressed("attack"):
#		shake_camera(.5,60,4, Vector2())

func handle_death_zone(body):
	player.velocity = Vector2()
	player.position = save_position

func start_falling_rock():
	var falling_rock = load("res://Levels/Grasslands0/fallingRock/fallingRock.tscn")
	var fallling_rock_node = falling_rock.instance()
	fallling_rock_node.global_position = $NPCs/moneygirl/rock.global_position
	add_child(fallling_rock_node)

func play_cutscene_dialog(name : String):
	DataResource.temp_dict_player.dialog_complete = false
	SceneControl.change_and_start_dialog(name)
	wait_dialog_complete = true


func _on_NextCutsceneTriger_body_entered(body):
	if cur_cut_scene_completed and cutscene_number == 2:
		$Mobs/FurballNPC.interact(player)

func start_glove_throw():
	var glove = load("res://Levels/Grasslands0/Glove/Glove.tscn")
	var glove_node = glove.instance()
	glove_node.global_position = $NPCs/moneygirl.global_position
	glove_node.velocity = Vector2(-1500 , -540)
	$NPCs.add_child(glove_node)

