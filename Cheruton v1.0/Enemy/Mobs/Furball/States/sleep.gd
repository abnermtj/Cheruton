extends baseState

func enter():
	owner.play_anim("sleep")

func update(delta):
	owner.velocity = Vector2.DOWN * 10
	owner.move()

