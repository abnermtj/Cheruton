extends Node2D

const SCN1 = "res://Levels/testBench/playerTestBench.tscn"
const EXPBAR = "HudLayer/Hud/StatBars/ExpBar"
const HEALTHBAR = "HudLayer/Hud/StatBars/HealthBar"

onready var main_menu = self
onready var options = $Bg/Options
onready var slider = $Bg/Options/Slider
onready var tween = $Tween
onready var canvas_modulate = $CanvasModulate
onready var general_player = $Bg/Cheruton/Player
onready var bg_player = $Bg/BgPlayer
onready var options_delay = $OptionsDelay
onready var cheruton_delay = $CherutonDelay
onready var cheruton = $Bg/Cheruton

onready var container = $Bg/Options/VBoxContainer

onready var play_position = $Bg/Options/VBoxContainer/Play.rect_position
onready var settings_position = $Bg/Options/VBoxContainer/Settings.rect_position
onready var quit_position = $Bg/Options/VBoxContainer/Quit.rect_position

var modulate_dec = "white"
var slider_active := false
var slider_enabled := false


func _ready():
	get_tree().get_root().call_deferred("move_child",main_menu, 1) 
	bg_player.play("water")
	SceneControl.settings_layer.get_node("Settings").connect("closed_settings", self, "back_to_mmenu")
	SceneControl.get_node("popUpGui").enabled = false
	tween_white_screen()
	slider_enabled = true

	cheruton.modulate.a = 0
	options.modulate.a = 0

# Gives a fadein effect
func tween_white_screen():
	tween.interpolate_property(canvas_modulate, "color", canvas_modulate.color, Color(1,1,1,1), 0.65, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(SceneControl.bg_music, "volume_db", -60, 0, 1.25, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

# When the tween of the relevant object is completed
func _on_Tween_tween_completed(object, key):
	if(object == canvas_modulate):
		cheruton_delay.start()
	elif(object == cheruton):
		options_delay.start()
	elif(object == options):
		enable_options()


func _on_CherutonDelay_timeout():
	tween.interpolate_property(cheruton, "modulate", cheruton.modulate, Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_OptionsDelay_timeout():
	tween.interpolate_property(options, "modulate", options.modulate, Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

#Enables the Buttons for use
func enable_options():
	for i in container.get_child_count():
		container.get_child(i).disabled = false


func _on_Play_pressed():
	SceneControl.button_click.play()
	general_player.play("button_pressed")

func _on_Settings_pressed():
	SceneControl.button_click.play()
	general_player.play("button_pressed")

func _on_Quit_pressed():
	SceneControl.button_click.play()
	general_player.play("button_pressed")


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
			SceneControl.change_scene(self, SCN1)

		settings_position:
			hide_options()
			general_player.play("to_settings")
		quit_position:
			get_tree().quit()


func hide_options():
	slider_active = false
	slider.hide()
	container.hide()

func back_to_mmenu():
	general_player.play("to_mmenu")



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

