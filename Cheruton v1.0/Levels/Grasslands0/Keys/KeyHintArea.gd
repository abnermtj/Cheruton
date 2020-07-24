extends Area2D

var perm_hide = false
func _ready():
	modulate.a = 0

func _on_Scene0_0_body_entered(body):
	if not perm_hide:
		$AnimationPlayer.play("fadeIn")

func _on_Scene0_0_body_exited(body):
	if not perm_hide: $AnimationPlayer.play("fadeOut")

func perm_hide():
	perm_hide = true
	$AnimationPlayer.play("fadeOut")
