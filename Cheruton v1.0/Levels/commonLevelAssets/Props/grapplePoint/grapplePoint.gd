extends StaticBody2D

const ENTERED = 0
const EXITED = 1
const ACTIVE_COLOR = Color(1,1,0)

var active = false setget setisActive

func _ready():
	add_to_group("hook_points")

	$RayCast2D.force_raycast_update()
	var col_pos = $RayCast2D.get_collision_point()
	if col_pos:
		var rope_length = clamp ((global_position - col_pos).length() - 64, 0, INF)
		rope_length /= 4 # because of scaling
		$Rope.region_rect = Rect2(0, 0, 3, rope_length)

		$End.global_position = col_pos + Vector2(0,4)
	else:
		$Rope.hide()
		$End.hide()


func setisActive(val):
	if val:
		modulate = ACTIVE_COLOR
	else:
		modulate = Color(1,1,1)

