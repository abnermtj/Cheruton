extends motionState

var coyote_timer : float # here incase playeer walks off an edge
var jump_timer : float
var jump_again : bool

func enter():
	owner.get_node( "AnimationPlayer").play("fall")
	coyote_timer = owner.COYOTE_TIME
	jump_again = false

func update(delta):
	coyote_timer -= delta
	jump_timer -= delta
	# CAPPING FALL SPEED
	owner.velocity.y = min( owner.TERM_VEL, owner.velocity.y + owner.GRAVITY * delta )

	var dir = get_input_direction().x

	if dir != 0:
		owner.velocity.x = lerp (owner.velocity.x,\
		 owner.MAX_VEL * dir,\
		 owner.AIR_ACCEL * delta)
# need to deal with look direction somehow
	else :
		owner.velocity.x = lerp( owner.velocity.x, 0, \
			owner.AIR_ACCEL * delta )

	owner.move_and_slide(owner.velocity, Vector2.UP)

	if Input.is_action_just_pressed( "btn_jump" ):
		# jump immediately after landing
		jump_timer = owner.JUMP_AGAIN_MARGIN
		jump_again = true
		# if fall off a ledge
		if coyote_timer > 0:
				emit_signal("finished", "jump")

	# landing
	if owner.is_on_floor():
		print ("jump again", jump_again)
		print ("jumptimer" , jump_timer)
		if jump_again and jump_timer >= 0:
			# jump again
			emit_signal("finished", "jump")
		else:
			# land
			if abs( owner.velocity.x ) > 1:
#				owner.anim_fx.play( "land_side" )
				emit_signal("finished", "run")
			else:
#				owner.anim_fx.play( "land" )
				emit_signal("finished", "idle")


