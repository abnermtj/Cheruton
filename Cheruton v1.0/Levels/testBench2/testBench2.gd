extends Level

onready var save_position = $player.position

func _ready():
	player.set_input_enabled(true)
func _input(event):
	if Input.is_action_just_pressed("reset"):
		var mob_instance = load("res://Enemy/Mobs/Furball/Furball.tscn").instance()

		mob_instance.global_position = save_position
		mob_instance.level = self
		mob_instance.player = player

		mob_instance.patrolling = true
		mob_instance.patrol_range_x = 400.0

		add_child(mob_instance)

func handle_death_zone(body):
	$player.velocity = Vector2()
	$player.position = save_position
