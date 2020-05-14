extends KinematicBody2D

# warning-ignore:unused_class_variable
export( bool )var fixed := false # don't use the word anchor
# warning-ignore:unused_class_variable
var pos_cur : Vector2
# warning-ignore:unused_class_variable
var pos_prv : Vector2

var has_collide = false
var y_limit = INF
var x_limit_right = INF

func set_fixed (v):
	fixed = v







