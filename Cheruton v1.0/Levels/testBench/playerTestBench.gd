extends Level

onready var save_position = $player.position

func _input(event):
	if Input.is_action_just_pressed("reset"):
		$player.velocity = Vector2()
		$player.position = save_position

#'delta': time passed since the previous frame.
func _physics_process(delta):
	pass

func _process(delta):
	pass
