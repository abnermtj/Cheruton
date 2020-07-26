extends Level

onready var save_position = $player.position
onready var cut_scene_player = $CutScenePlayer

var cur_cut_scene_completed = false
var flying_sword

func _ready():
	DataResource.change_health(50) # fix next time
#	bg_music_file = "res://Sound/MusicDebug/Frantic-Gameplay.ogg"
	story_file = "res://Levels/Grasslands0/Stories/Baked/Grasslands0Dialog.tres"
	entrace_to_pos_dict = {0: Vector2(-200, 188),\
							1: Vector2(7866 ,2552)}
	if not enter_point: enter_point = 0 # default must be set for all scenes

	player_spawn_pos = entrace_to_pos_dict[enter_point] # enter point set by scene control

	#debug
	player_spawn_pos = Vector2(3028, -1936)
	$player.set_input_enabled(true)
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
#	print(cutscene_number, cutscene_index)
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
			if cutscene_index == 4:
#				DataResource.dict_player.completed_cutscenes["grasslands0_2"] = true
				end_cutscene()
				return
		4:
			if cutscene_index == 4:
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

#
func _input(event):
#	if Input.is_action_just_pressed("reset"):
#		player.velocity = Vector2()
#		player.position = save_position
#
#		var mob = preload("res://Enemy/Mobs/Furball/Furball.tscn")
#		var instance = mob.instance()
#		instance.position = save_position
#		$Mobs.add_child(instance)

	if Input.is_action_just_pressed("attack"):
		$Hints/Scene0_0._on_Scene0_0_body_entered(null)
#		shake_camera(.5,60,4, Vector2())

func on_player_dead():
	player.global_position = player_spawn_pos
	DataResource.change_health(999)

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

func instance_flying_sword():
	var load_sword = load("res://Player/ActualPlayer/FlyingSword/flyingSword.tscn")
	flying_sword = load_sword.instance()

	flying_sword.connect("sword_result", player, "on_sword_result")
	flying_sword.connect("sword_result", self, "on_sword_result")
	player.connect("flying_sword_command", flying_sword, "_on_flyingSword_command")

	flying_sword.hide()
	add_child(flying_sword)

	flying_sword.global_position = player.global_position + Vector2 (2000, -2000)
	flying_sword.active = true
	flying_sword.z_index = 1
	flying_sword.show()

	flying_sword._on_flyingSword_command(2, 0)

func on_sword_result(result, vector1, vector2):
	if result == 2 and cutscene_number == 4:
		next_cutscene()

func shake_camera(time : float, freq : float, power : float, dir: Vector2):
	camera.shake(time, freq, power, dir)

