extends Area2D

var interaction_type

func _ready():
	add_to_group("interactibles")
	interaction_type = "cutscene"

func pend_interact():
	owner.pend_interact()

func unpend_interact():
	owner.unpend_interact()

func interact(body):
	owner.interact(body)
