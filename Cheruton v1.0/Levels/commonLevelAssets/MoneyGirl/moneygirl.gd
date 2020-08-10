extends StaticNPC
# Note the 2 sprite soltion is hacky and should be replaced when u have better shader knowledge,
# it was done because the outline shader overwrites the shadows drawn by the engine light2d

onready var anim_player = $AnimationPlayer
onready var magic_shot = preload("res://Levels/commonLevelAssets/MoneyGirl/MoneyGirlShot.tscn")

func _ready():
	._ready()
	sprite = $bodyRotate/Sprite
	sprite2 = $bodyRotate/Sprite2

	$bodyRotate/staffPos.hide()

func play_anim(name : String):
	if name != "on_broom_idle": $bodyRotate.position = Vector2()
	anim_player.clear_queue()
	anim_player.play(name)
	anim_player.advance(0)
func queue_anim(name : String):
	anim_player.queue(name)

func set_anim_speed(speed : float):
	anim_player.playback_speed = speed

func interact(body : Node):
	if not interact_enabled:
		DataResource.temp_dict_player.dialog_complete = true
		return

	.interact(body)
	level.next_cutscene()
	DataResource.temp_dict_player.dialog_complete = false
	level.wait_dialog_complete = true

func shoot():
	$AnimationPlayerStaff.play("Staff")

func instance_magic_shot():
	var instance = magic_shot.instance()

	instance.global_position = $bodyRotate/staffPos/tipStaffPos.global_position
	instance.goal_obj = level.get_node("Mobs/FurballTarget")
	instance.get_node("hurtBox").obj = self
	instance.level = level

	level.add_child(instance)
