extends Node2D

var looted  := false

signal chest_looted

onready var player = $Player

func _ready():
	var _conn0 = connect("chest_looted", self, "_on_Chest_chest_looted")

func loot_chest():
	if(!looted):
		#player.play("open")
		#Loot.determine_loot("test")
		emit_signal("chest_looted")

func _on_Chest_chest_looted():
	#player.play("close")
	looted = true
	#self.free()
