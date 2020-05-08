extends VerletChain

var dir_cur = 1 setget _set_dir
var is_center : = false setget _set_center

func _set_dir( v ):
	if dir_cur != v:
		dir_cur = v
		if not is_center:
			$anchor.position = Vector2( -1 * dir_cur, 1 )
		$base.scale.x = dir_cur
		for loop in loops:
			loop.get_node( "Sprite" ).scale.x = dir_cur

func _set_center( v ):
	is_center = v
	if is_center:
		$anchor.position = Vector2( 0, 1 )
	else:
		$anchor.position = Vector2( -1 * dir_cur, 1 )
