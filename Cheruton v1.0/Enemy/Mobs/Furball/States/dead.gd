extends baseState

const SPEED = 3200
const FREEZE_TIME = .02

var timer : float
var dust_emit_on_cooldown = false

func enter():
	var obj_pos = owner.hitter_pos
	var move_dir = (owner.global_position - obj_pos ).normalized()

	owner.shake_camera(.08, 20.0, 64, -move_dir)
	owner.play_anim("die")
	get_tree().paused = false

	owner.velocity.x =  SPEED * move_dir.x

	timer = FREEZE_TIME

func update(delta):
	timer -= delta
	if timer > 0 : return

	owner.velocity.x = lerp(owner.velocity.x,0 , delta * 4)
	owner.velocity.y = clamp(owner.velocity.y + owner.GRAVITY/3 * delta, -INF, owner.TERMINAL_VELOCITY)

	owner.move()

	var col = owner.get_slide_collision(0)

	if col and not dust_emit_on_cooldown and owner.velocity.length() > 150:
		dust_emit_on_cooldown = true
		$dustCooldown.start(.05)

		var dust_instance = owner.dust.instance()
		dust_instance.global_position = col.position
		dust_instance.rotation = col.normal.angle_to(Vector2.UP)
		dust_instance.emitting = true

		owner.level.add_child(dust_instance)


func _on_dustCooldown_timeout():
	dust_emit_on_cooldown = false
