extends Level

onready var save_position = player.position
onready var anim_player = $AnimationPlayer
const fur = preload("res://Enemy/Mobs/Furball/Furball.tscn")

func _ready():
	player.set_isInputEnabled(true)

func _input(event):
	if Input.is_action_just_pressed("reset"):
		player.velocity = Vector2()
		player.position = save_position
		var new_fur = fur.instance()
		new_fur.global_position = save_position + Vector2(rand_range(-100, 100), 0);
		new_fur.player = player
		new_fur.level = self
		add_child(new_fur)

func handle_death_zone(body):
	player.velocity = Vector2()
	player.position = save_position

func play_anim(string):
	anim_player.play(string)
