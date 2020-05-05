extends Control


func _ready():
	pass 


func _on_Play_pressed():
	LoadScrnGlobal.goto_scene("res://Player/Stats/Stats.tscn")


func _on_Exit_pressed():
	#DataResource.save_player() #- can save before going back to mm??
	get_tree().quit()
