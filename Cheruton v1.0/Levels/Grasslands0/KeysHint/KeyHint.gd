extends Node2D

export var key_name : String = ""

func _ready():
	if key_name.length() == 1:
		$Key.show()
		$Key.text = key_name
	else:
		$NonTextKey.show()
		match key_name:



