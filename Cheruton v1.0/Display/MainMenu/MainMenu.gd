extends Node2D

const SCN1 = "res://Levels/testBench/playerTestBench.tscn"
const SCN2 = "res://Levels/Hometown/Hometown.tscn"
const SCN3 = "res://Levels/spiderBosstestBench/SpiderbossTestScene.tscn"
const EXPBAR = "HudLayer/Hud/StatBars/ExpBar"
const HEALTHBAR = "HudLayer/Hud/StatBars/HealthBar"

onready var settings = $Settings
onready var options = $Background/Options
onready var timer_options = $Timer
onready var slider = $Background/Options/Slider
onready var tween = $Background/Options/Slider/Tween

onready var white_screen = $WhiteScreen
onready var options_delay = $OptionsDelay

onready var container = $Background/Options/VBoxContainer

onready var play_position = $Background/Options/VBoxContainer/Play.rect_position
onready var settings_position = $Background/Options/VBoxContainer/Settings.rect_position
onready var quit_position = $Background/Options/VBoxContainer/Quit.rect_position


onready var bg_music_fill

var modulate_dec = "white"
var slider_active := false
var tween_status := false

func _ready():
	white_screen.modulate.a = 1.0
	options.modulate.a = 0
	

func _process(delta):
	modulate_func()

# Creates a startup effect
func modulate_func():
	match modulate_dec:
		"white":
			if(white_screen.modulate.a < 0.01):
				modulate_dec = "idle"
				options_delay.start()
			else:
				white_screen.modulate.a -= 0.01

		"options":
			if(options.modulate.a > 0.99):
				modulate_dec = "idle"
				enable_options()
			else:
				options.modulate.a += 0.03


func _on_OptionsDelay_timeout():
	white_screen.hide()
	modulate_dec = "options"
	
#Enables the Buttons for use
func enable_options():
	for i in container.get_child_count():
		container.get_child(i).disabled = false

func _on_Play_pressed():
	SceneControl.emit_signal("init_statbar")
	SceneControl.load_screen(SCN1, true, true)
	queue_free()

func _on_Settings_pressed():
	options.hide()
	settings.show()


func _on_Quit_pressed():
	get_tree().quit()


func _on_Timer_timeout():
	options.show()


func _on_Play_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, play_position.y)
	slide_to_position(new_position)

func _on_Settings_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, settings_position.y)
	slide_to_position(new_position)

func _on_Quit_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, quit_position.y)
	slide_to_position(new_position)

# Slides the slider to the intended position, or shows it there if not visible
func slide_to_position(new_position):
	# Offset of position
	new_position.y += container.rect_position.y
	if(!tween_status):
		var old_position = slider.rect_position
		if(slider_active):
			tween.interpolate_property(slider, "rect_position", old_position, new_position, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween_status = true
			tween.start()
		else:
			slider.rect_position.y = new_position.y
			slider.show()
			slider_active = true


func _on_Tween_tween_completed(object, key):
	tween_status = false



