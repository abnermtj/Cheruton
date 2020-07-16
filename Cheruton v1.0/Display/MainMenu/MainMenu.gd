extends Node2D

const SCN1 = "res://Levels/testBench/playerTestBench.tscn"
const SCN2 = "res://Levels/Hometown/Hometown.tscn"
const SCN3 = "res://Levels/spiderBosstestBench/SpiderbossTestScene.tscn"
const EXPBAR = "HudLayer/Hud/StatBars/ExpBar"
const HEALTHBAR = "HudLayer/Hud/StatBars/HealthBar"

onready var options = $Background/Options
onready var slider = $Background/Options/Slider
onready var tween = $Tween
onready var canvas_modulate = $CanvasModulate
onready var player = $Background/Cheruton/Player

onready var options_delay = $OptionsDelay

onready var container = $Background/Options/VBoxContainer

onready var play_position = $Background/Options/VBoxContainer/Play.rect_position
onready var settings_position = $Background/Options/VBoxContainer/Settings.rect_position
onready var quit_position = $Background/Options/VBoxContainer/Quit.rect_position

onready var bg_music_file

var modulate_dec = "white"
var slider_active := false
var slider_enabled := false

func _ready():
	SceneControl.settings_layer.get_node("Settings").connect("closed_settings", self, "back_to_mmenu")
	SceneControl.get_node("popUpGui").enabled = false
	tween_white_screen()
	slider_enabled = true
	options.modulate.a = 0

# Gives a fadein effect
func tween_white_screen():
	tween.interpolate_property(canvas_modulate, "color", canvas_modulate.color, Color(1,1,1,1), 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

# When the tween of the relevant object is completed
func _on_Tween_tween_completed(object, key):
	if(object == canvas_modulate):
		options_delay.start()
	elif(object == options):
		enable_options()


func _on_OptionsDelay_timeout():
	tween.interpolate_property(options, "modulate", options.modulate, Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

#Enables the Buttons for use
func enable_options():
	for i in container.get_child_count():
		container.get_child(i).disabled = false
	

func _on_Play_pressed():
	player.play("button_pressed")

func _on_Settings_pressed():
	player.play("button_pressed")

func _on_Quit_pressed():
	player.play("button_pressed")


func _on_Player_animation_finished(anim_name):
	if(anim_name == "to_settings"):
		SceneControl.settings_layer.show()
	elif(anim_name == "to_mmenu"):
		container.show()
	elif(anim_name == "button_pressed"):
		perform_button_action()
		

func perform_button_action():
	var btn_pos = slider.rect_position - container.rect_position
	
	match btn_pos:
		play_position:
			slider_enabled = false
			SceneControl.emit_signal("init_statbar")
			SceneControl.load_screen(SCN1)
			queue_free()
		settings_position:
			hide_options()
			player.play("to_settings")
		quit_position:
			get_tree().quit()


func hide_options():
	slider_active = false
	slider.hide()
	container.hide()

func back_to_mmenu():
	player.play("to_mmenu")
	
	

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
	if(slider_enabled):
		new_position.y += container.rect_position.y
		var old_position = slider.rect_position
		if(slider_active):
			tween.interpolate_property(slider, "rect_position", old_position, new_position, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			tween.start()
		else:
			slider.rect_position.y = new_position.y
			slider.show()
			slider_active = true
