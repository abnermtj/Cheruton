extends motionState

var keypress_timer : float # how long you can keep jumpig up to boost height
#var climb_timer : float


func enter() -> void:
	owner.has_jumped = true
	print( "Starting jump" )
	owner.velocity.y = owner.JUMP_VEL # old speed kept
	owner.velocity = owner.move_and_slide( owner.velocity, Vector2.UP )
	owner.get_node("AnimationPlayer").play("jump")
	keypress_timer = 0.2

func update( delta ):
	owner.velocity.y = min( owner.TERM_VEL, owner.velocity.y + owner.GRAVITY * delta )
	if keypress_timer >= 0:
		keypress_timer -= delta
		if keypress_timer < 0 or Input.is_action_just_released( "jump" ):
			keypress_timer = -1.0
			owner.velocity.y *= owner.JUMP_RELEASE_SLOWDOWN # reduces speed on jump release
	# steering here
	var input_dir = get_input_direction()
	update_look_direction(input_dir)
	var dir = input_dir.x
	# if we are steering
	if dir:
		owner.velocity.x = lerp( owner.velocity.x, \
			owner.MAX_VEL * dir, \
			owner.AIR_ACCEL * delta ) # moves towards goal velocity
	else: # if not moving velocity tends to zero
		owner.velocity.x = lerp( owner.velocity.x, 0, \
			owner.AIR_ACCEL * delta )

	owner.move_and_slide( owner.velocity, \
			Vector2.UP )  #Up makes it such that if the collision normal is the same, as up then stop

#	if owner.is_on_floor():
#		owner.get_node("AnimationPlayer").play("land")
#		emit_signal("finished", "previous")
#		print("land")
	if owner.is_on_ceiling():
		owner.velocity.y = 0.0
		emit_signal("finished","fall")
	else:
		print(owner.velocity.y)
		if owner.velocity.y > 0:
			print("change to fall")
			emit_signal("finished","fall")

	return false
