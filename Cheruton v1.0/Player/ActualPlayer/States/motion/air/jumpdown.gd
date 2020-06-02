extends airState

const TERM_VEL = 3000

func enter():
	owner.set_collision_mask_bit (8,false)

func update(delta):
	owner.velocity.y = min( TERM_VEL, owner.velocity.y + owner.GRAVITY * delta )
	owner.move()
	if not owner.is_between_tiles:
		emit_signal("finished", "fall")

func exit():
	owner.set_collision_mask_bit (8,true)
