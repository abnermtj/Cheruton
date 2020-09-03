extends baseState

const HIT_TIME = 0.2
var hit_timer : float

func enter():
	hit_timer = HIT_TIME
	owner.set_player_invunerable(HIT_TIME) # player regains control before getting out of this state
	owner.play_anim_fx_color("hit")

	owner.velocity = owner.hit_dir.normalized() * 400

func update( delta ):
	hit_timer -= delta
	if hit_timer <= 0:
		emit_signal("changeState", "idle")

	owner.move()
	if owner.is_on_floor():
		owner.velocity.x *= 0.98 # player feed back
