extends Control

func _ready():
	Cursor.init_default_cursor()


func _on_Button_pressed():
	Cursor.set_cursor(1)
