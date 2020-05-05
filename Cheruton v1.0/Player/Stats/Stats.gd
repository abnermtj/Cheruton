extends Control


func _ready():
	$ExpBar.initbar()
	$HealthBar.initbar()


func _on_increase_pressed():
	DataFunctions.change_health(rand_range(1,25))


func _on_decrease_pressed():
	DataFunctions.change_health(rand_range(-1,-25))


func _on_incexp_pressed():
	DataFunctions.add_exp(rand_range(1,25))
