extends baseState

var hit_timer : float

func enter():
	hit_timer = 0.2
	owner.set_player_invunerable(.500) # player regains control before getting out of this state
	owner.play_anim_fx("hit")
func update( delta ):
	hit_timer -= delta
	if hit_timer <= 0:
		emit_signal("finished", "idle")
	owner.move()
	if owner.is_on_floor():
		owner.velocity.x *= 0.98 # player feels slowed down

