extends State_Enemy

var timer : float

func initialize():
	timer = 0.05
	obj.anim_next = "hit"
	# Determines where the attack cam from
	obj.velocity = obj.hit_dir.normalized() * 150
	if obj.velocity.x > 0:
		obj.dir_next = 1
	elif obj.velocity.x < 0:
		obj.dir_next = -1
	#game.camera_shake( 0.10, 60, 4, obj.hit_dir.normalized() )
	obj.get_node("DamageBox/DamageCollision").disabled = true
	obj.get_node("HitBox/HitboxCollision").disabled = true


func run(delta):
	#obj.get_node( "hitbox/hitbox_collision" ).disabled = false
	while (timer <= 0):
		timer -= delta
	fsm.state_next = fsm.states.cooldown
	obj.velocity.y = min(obj.velocity.y + 500 * delta, 160)
	obj.velocity.x *= 0.95
	if (!obj.check_wall()):
		obj.velocity = obj.move_and_slide_with_snap( obj.velocity, obj.get_node( "rotate" ).scale.y * Vector2.DOWN * 8, obj.get_node( "rotate" ).scale.y * Vector2.UP )
	
	# Cooldown phase before moving
	obj.get_node("HitBox/HitboxCollision").disabled = false
	obj.is_hit = false
	timer = 0.2
	while (timer <= 0):
		timer -= delta
	fsm.state_next = fsm.states.Patrol #debug - change to attack
	
func terminate():
	print(fsm.state_prev)

	obj.get_node("DamageBox/DamageCollision").disabled = false
