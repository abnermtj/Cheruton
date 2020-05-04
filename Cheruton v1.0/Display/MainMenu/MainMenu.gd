extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Exit_pressed():
	#DataResource.save_player() #- can save before going back to mm??
	get_tree().quit()
