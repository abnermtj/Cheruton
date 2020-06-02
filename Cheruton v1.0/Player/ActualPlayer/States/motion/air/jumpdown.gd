extends airState

func enter():
	owner.slide_collision.disabled = true
	owner.body_collision.disabled = true

func update(delta):
