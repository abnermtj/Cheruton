extends Area2D

var perm_hide = false setget set_perm_hide

onready var tween = $Tween

func _ready():
	modulate.a = 0

func set_perm_hide(val):
	perm_hide = val

	if val == true:
		_on_Scene0_0_body_exited(null)
		disconnect("body_entered", self, "_on_Scene0_0_body_entered")
		disconnect("body_exited", self, "_on_Scene0_0_body_exited")

func _on_Scene0_0_body_entered(body):
	tween.stop_all()
	tween.interpolate_property(self, "modulate", modulate, Color(1, 1, 1, 1), 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()

func _on_Scene0_0_body_exited(body):
	tween.stop_all()
	tween.interpolate_property(self, "modulate", modulate, Color(1, 1, 1, 0), 1.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
