extends baseState

var player_dir

func enter():
	owner.play_anim("attack")
	owner.velocity.x = 0

func update(delta):
	player_dir = (owner.player.global_position - owner.global_position).normalized()
	owner.look_dir = Vector2(sign(player_dir.x),0)

func on_anim_done():
	emit_signal("finished", "idle")
