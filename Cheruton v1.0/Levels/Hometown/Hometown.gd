extends Level

onready var save_position = $player.position

func _ready():
	story_file = "res://Levels/Hometown/Stories/Baked/HometownDialog.tres"

	$Buildings.add_to_group("one_way_platforms")
	$Props.add_to_group("one_way_platforms")
func _input(event):
	if Input.is_action_just_pressed("reset"):
		$player.velocity = Vector2()
		$player.position = save_position

func handle_death_zone(body):
	$player.velocity = Vector2()
	$player.position = save_position
