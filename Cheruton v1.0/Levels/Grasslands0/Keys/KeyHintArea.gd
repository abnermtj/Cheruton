extends Area2D

var perm_hide = false
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
#func _on_Scene0_0_body_entered(body):
#	if not perm_hide and not $AnimationPlayer.is_playing():
#		$AnimationPlayer.play("fadeIn")
#
#func _on_Scene0_0_body_exited(body):
#	if not perm_hide and not $AnimationPlayer.is_playing():
#		$AnimationPlayer.play("fadeOut")

func perm_hide():
	perm_hide = true
#	$AnimationPlayer.play("fadeOut")
