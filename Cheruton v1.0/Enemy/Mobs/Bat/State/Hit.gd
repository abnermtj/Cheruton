extends State_Enemy

#HIT: Enemy has been just hit by an external attack by player
var prev_state
var timer : float

func initialize():
	timer = 0.5
	#game.camera_shake( 0.10, 60, 4, obj.hit_dir.normalized() )
	obj.get_node("HitBox/HitCollision").disabled = true

func run(delta):
	aerial_pos_edit()
	#obj.get_node( "hitbox/hitbox_collision" ).disabled = false
	timer -= delta
	if (timer <= 0):
		fsm.state_next = fsm.states.ProcessHit
		obj.velocity.x *= 0.95
		obj.velocity = obj.move_and_slide_with_snap( obj.velocity, obj.get_node("Rotate").scale.y * Vector2.DOWN * 8, obj.get_node("Rotate").scale.y * Vector2.UP )
		
func terminate():
	obj.get_node("HitBox/HitCollision").disabled = false
	obj.is_hit = false
	prev_state = fsm.state_prev
