extends Node2D

const SCN1 = "res://Levels/testBench/playerTestBench.tscn"
const SCN2 = "res://Levels/Hometown/Hometown.tscn"
const SCN3 = "res://Levels/spiderBosstestBench/SpiderbossTestScene.tscn"
const EXPBAR = "HudLayer/Hud/StatBars/ExpBar"
const HEALTHBAR = "HudLayer/Hud/StatBars/HealthBar"

onready var settings = $Settings
onready var options = $Background/Options
onready var timer_options = $Timer
onready var white_screen = $WhiteScreen
onready var options_delay = $OptionsDelay

onready var bg_music_fill

var modulate_dec = "white"

func _process(delta):
	#white_screen.modulate.a -= 0.01
	modulate_func()

# Creates a startup effect
func modulate_func():
	match modulate_dec:
		"white":
			white_screen.modulate.a -= 0.01

			if(white_screen.modulate.a < 0.01):
				modulate_dec = "idle"
				options_delay.start()

		"options":
			options.modulate.a += 0.03
			if(options.modulate.a > 0.99):
				modulate_dec = "idle"


func _on_OptionsDelay_timeout():
	modulate_dec = "options"

func _on_Quit_pressed():
	get_tree().quit()


func _on_Timer_timeout():
	options.show()



