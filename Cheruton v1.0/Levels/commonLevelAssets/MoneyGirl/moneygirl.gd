extends StaticNPC
# Note the 2 sprite soltion is hacky and should be replaced when u have better shader knowledge,
# it was done because the outline shader overwrites the shadows drawn by the engine light2d

onready var anim_player = $AnimationPlayer
onready var magic_shot = preload("res://Levels/commonLevelAssets/MoneyGirl/MoneyGirlShot.tscn")
onready var level = get_parent().get_parent()
onready var player = level.get_node("player")

func _ready():
	._ready()
	sprite = $bodyRotate/Sprite
	sprite2 = $bodyRotate/Sprite2

func play_anim(name):
	anim_player.clear_queue()
	anim_player.play(name)
	anim_player.advance(0)
func queue_anim(name):
	anim_player.queue(name)

func set_anim_speed(speed):
	anim_player.playback_speed = speed

func set_outline_enabled(val):
	sprite.visible = val

func interact(body):
	.interact(body)
	SceneControl.cur_level.next_cutscene()
	DataResource.temp_dict_player.dialog_complete = false
	SceneControl.cur_level.wait_dialog_complete = true

func shoot():
	$AnimationPlayerStaff.play("Staff")

func instance_magic_shot():
	var instance = magic_shot.instance()

	instance.global_position = $bodyRotate/staffPos/tipStaffPos.global_position
	instance.goal_obj = level.get_node("Mobs/FurballTarget")
	instance.get_node("hurtBox").obj = self

	level.add_child(instance)
