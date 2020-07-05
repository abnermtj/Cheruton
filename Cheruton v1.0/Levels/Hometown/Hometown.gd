extends Level

onready var save_position = $player.position


func _input(event):
	if Input.is_action_just_pressed("reset"):
		$player.velocity = Vector2()
		$player.position = save_position

func handle_death_zone(body):
	$player.velocity = Vector2()
	$player.position = save_position
