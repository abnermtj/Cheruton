extends Area2D

onready var tele_pos = get_parent().get_node(name + "_pos").global_position

# player enters()
func _on_zone1_0_body_entered(body):
	body.zone = self

func _on_zone1_0_body_exited(body):
	if body.zone == self:
		body.zone = null
