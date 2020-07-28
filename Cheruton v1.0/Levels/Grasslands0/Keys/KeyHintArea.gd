extends Area2D

var perm_hide : bool setget set_perm_hide
var player_inside = false


func _ready():
	modulate.a = 0

func _process(delta):

	if get_overlapping_bodies():
		player_inside = true
	else:
		player_inside = false

	if perm_hide:
		player_inside = false
	modulate.a = lerp(modulate.a, int(player_inside), 4*delta)

func set_perm_hide(val):
	perm_hide = val
