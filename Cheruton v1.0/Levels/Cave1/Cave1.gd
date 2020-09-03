extends Level

onready var save_position = player.position
onready var anim_player = $AnimationPlayer

func _ready():
	player.set_isInputEnabled(true)

func _input(event):
	if Input.is_action_just_pressed("reset"):
		player.velocity = Vector2()
		player.position = save_position

func handle_death_zone(body):
	player.velocity = Vector2()
	player.position = save_position

func play_anim(string):
	anim_player.play(string)
