extends KinematicBody2D

onready var sprite = $Sprite

var velocity : Vector2
var interact_enabled = true

func _physics_process(delta):
	velocity.x *= .978
	velocity.y += 2400 * delta

	velocity.y = clamp (velocity.y, -INF, 2400)
	move_and_slide(velocity, Vector2.UP)

	if is_on_floor():
		velocity.x *= .86

func pend_interact():
	sprite.material.set_shader_param("width", .5)

func unpend_interact():
	sprite.material.set_shader_param("width", 0)

func interact(body):
	if not interact_enabled: return
	interact_enabled = false

	var level = get_parent().get_parent()
	level.next_cutscene()
	DataResource.temp_dict_player.dialog_complete = true
	level.wait_dialog_complete = false

	queue_free()
