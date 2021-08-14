extends baseState

func enter():
	owner.play_anim("sleep")

func update(delta):
	owner.velocity += Vector2.DOWN * 1000 * delta
	owner.velocity.y = max( -500 , owner.velocity.y)
	owner.move()

