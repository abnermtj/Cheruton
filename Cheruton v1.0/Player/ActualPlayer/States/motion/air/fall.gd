extends motionState

var coyote_timer : float # here incase playeer walks off an edge
var jump_timer : float
var jump_again : bool
var jump_count : int

func enter():
	owner.get_node( "AnimationPlayer").play("fall")
	coyote_timer = owner.COYOTE_TIME
	jump_again = false


func update(delta):
	coyote_timer -= delta
	jump_timer -= delta
	# CAPPING FALL SPEED
	owner.velocity.y = min( owner.TERM_VEL, owner.velocity.y + owner.GRAVITY * delta )

	var input_dir = get_input_direction()
	update_look_direction(input_dir)
	var dir = input_dir.x

	if dir != 0:
		owner.velocity.x = lerp (owner.velocity.x,\
		 owner.MAX_VEL * dir,\
		 owner.AIR_ACCEL * delta)
# need to deal with look direction somehow
	else :
		owner.velocity.x = lerp( owner.velocity.x, 0, \
			owner.AIR_ACCEL * delta )

	owner.move_and_slide(owner.velocity, Vector2.UP)

	if Input.is_action_just_pressed( "jump" ):
		# jump immediately after landing
		jump_timer = owner.JUMP_AGAIN_MARGIN
		jump_again = true
		if coyote_timer > 0 and not owner.has_jumped:  # when accidentally falling off edges
				emit_signal("finished", "jump")
				return

	# landing
	if owner.is_on_floor():
		owner.has_jumped = false
		owner.get_node("AnimationPlayer").play("land")
		if (jump_again and jump_timer >= 0):
			owner.get_node("states").states_stack.pop_front()
			emit_signal("finished", "jump")
		else:
			# land
			if owner.get_node("states").states_stack.size() == 1:
				emit_signal("finished", "idle")
			else:
				emit_signal("finished", "previous")


