extends StaticBody2D

const ENTERED = 0
const EXITED = 1
const ACTIVE_COLOR = Color(1,1,0)
var active = false setget set_active

func set_active(val):
	if val:
		modulate = ACTIVE_COLOR
	else:
		modulate = Color(1,1,1)

