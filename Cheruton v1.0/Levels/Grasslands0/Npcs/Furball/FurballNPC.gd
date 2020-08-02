extends StaticNPC

onready var FurballMob = preload("res://Enemy/Mobs/Furball/Furball.tscn")

func ready():
	dialog_name = "cutscene2_0"

	add_to_group("needs_level_ref", true)
	add_to_group("needs_player_ref", true)

func interact(body):
	var instance = FurballMob.instance()
	instance.global_position = global_position
	instance.name = "FurballTarget"
	instance.level = level
	instance.player = player

	get_parent().add_child(instance)

	instance.change_state("jump")

	get_parent().get_parent().next_cutscene()
	queue_free()
