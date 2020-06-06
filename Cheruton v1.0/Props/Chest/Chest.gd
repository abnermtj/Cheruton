extends Node2D


signal looted


func _ready():
	$Chest.play("open")
	#Loot.determine_loot("test")
	yield(get_tree().create_timer(2), "timeout")
	emit_signal("looted")


func _on_Chest_looted():
	$Chest.play("close")
