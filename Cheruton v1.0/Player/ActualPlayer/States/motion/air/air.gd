extends motionState

class_name airState

const WALL_SLIDE_THRESHHOLD = -100 # max y velocity to goto wall slide
var already_hooked = false

func update(delta):
	owner._update_wall_direction()
	if owner.wall_direction != 0 and owner.velocity.y > WALL_SLIDE_THRESHHOLD: # if there is a nearby wall and player is falling fast enough
		emit_signal("finished", "wallslide")

func update_idle(delta):
	pass
