extends baseState

class_name spiderBaseAttack

func update():
	if not owner.attacking:
		emit_signal("finished","idle")
