extends Level

onready var save_position = $player.position
onready var cut_scene_player = $CutScenePlayer
onready var falling_rock = $fallingRock
var cut_scene = true

func _ready():
	._ready()

	bg_music_file = "res://Sound/MusicDebug/Frantic-Gameplay.ogg"

	entrace_to_pos_dict = {0: Vector2(-200, 188),\
							1: Vector2(7866 ,2552)}
	if not enter_point: enter_point = 0 # default msut be set for all scenes

	player_spawn_pos = entrace_to_pos_dict[enter_point] # enter point set by scene control

	if cut_scene: play_cutscene()

func play_cutscene():
	cut_scene_player.play("cutscene2")

func _input(event):
	if Input.is_action_just_pressed("reset"):
		player.velocity = Vector2()
		player.position = save_position

func handle_death_zone(body):
	player.velocity = Vector2()
	player.position = save_position

func start_falling_rock():
	falling_rock.global_position = $npcs/moneygirl/rock.global_position
	falling_rock.show()
	falling_rock.gravity_scale = 1

