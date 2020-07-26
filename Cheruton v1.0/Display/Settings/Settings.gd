extends Control

const LMB = "InputEventMouseButton : button_index=BUTTON_LEFT, pressed=false, position=(0, 0), button_mask=0, doubleclick=false"
const RMB = "InputEventMouseButton : button_index=BUTTON_RIGHT, pressed=false, position=(0, 0), button_mask=0, doubleclick=false"


onready var master_bar = $Settings/Container/Main/Contents/BaseAudio/Rect/Contents/SoundBar/MainVolBar
onready var music_bar = $Settings/Container/Main/Contents/BaseAudio/Rect/Contents/SoundBar/MusicVolBar
onready var sfx_bar = $Settings/Container/Main/Contents/BaseAudio/Rect/Contents/SoundBar/SFXVolBar


onready var container = $Settings/Container
onready var contents = $Settings/Container/Main/Contents
onready var controls_column = $Settings/Container/Main/Contents/BaseControls/Column
onready var controls_button = $Settings/Container/Main/Contents/BaseControls/Buttons

onready var slider = $Settings/Slider
onready var tween = $Tween
onready var controls = $Settings/Container/Main/Contents/Options/Controls
onready var audio = $Settings/Container/Main/Contents/Options/Audio
onready var game = $Settings/Container/Main/Contents/Options/Game
onready var back = $Settings/Container/Main/Contents/Options/Back

onready var base_controls = $Settings/Container/Main/Contents/BaseControls
onready var base_audio = $Settings/Container/Main/Contents/BaseAudio
onready var base_game = $Settings/Container/Main/Contents/BaseGame
onready var base_empty = $Settings/Container/Main/Contents/BaseEmpty

var slider_active := false
var controls_set := -1

onready var active_tab = base_empty

signal closed_settings

func _ready():
	init_key_bindings()
	controls_set_column("Next")
	init_bar_vals()
	connect_functions()

func init_key_bindings():
	var columns = controls_column.get_child_count()
	for i in columns:
		var column_node = controls_column.get_child(i).get_node("Mapping")
		var bindings = column_node.get_child_count()
		for j in bindings:
			var current_binding = column_node.get_child(j).get_child(0)
			var btn_text = InputMap.get_action_list(current_binding.name)[0].as_text()
			btn_text = check_mouse_text(btn_text)
			set_text(current_binding, false, btn_text)

func set_text(node, unassign := true, new_value := ""):
	if(unassign):
			node.text = "Unassigned"
	else:
			node.text = new_value

func check_mouse_text(btn_text):
	if(btn_text == RMB):
		return "Right Mouse"
	elif(btn_text == LMB):
		return "Left Mouse"
	return btn_text

func controls_set_column(type):
	if(controls_set != -1):
		controls_column.get_child(controls_set).hide()
	match type:
		"Prev":
			controls_set -= 1
		"Next":
			controls_set += 1
			
	match controls_set:
		0:
			controls_button.get_node("Previous").hide()
		1:
			controls_button.get_node("Previous").show()
			controls_button.get_node("Next").show()
		2:
			controls_button.get_node("Next").hide()

	controls_column.get_child(controls_set).show()

func init_bar_vals():
	master_bar.value = (DataResource.dict_settings.audio_master + 60) / 60 * 100
	music_bar.value = (DataResource.dict_settings.audio_music + 60) / 60 * 100
	sfx_bar.value = (DataResource.dict_settings.audio_sfx + 60) / 60 * 100

func connect_functions():
	var _conn1 = DataResource.connect("change_audio_master", self, "change_master_vol")
	var _conn2 = DataResource.connect("change_audio_music", self, "change_music_vol")
	var _conn3 = DataResource.connect("change_audio_sfx", self, "change_sfx_vol")

func _on_Previous_pressed():
	SceneControl.button_click.play()
	controls_set_column("Prev")

func _on_Next_pressed():
	SceneControl.button_click.play()
	controls_set_column("Next")


	
func _on_MuteToggle_pressed():
	DataResource.dict_settings.is_mute = !DataResource.dict_settings.is_mute
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), DataResource.dict_settings.is_mute)

func change_master_vol():
	var end = (DataResource.dict_settings.audio_master + 60) / 60 * 100
	animate_healthbar(master_bar, end)

func change_music_vol():
	var end = (DataResource.dict_settings.audio_music + 60) / 60 * 100
	animate_healthbar(music_bar, end)

func change_sfx_vol():
	var end = (DataResource.dict_settings.audio_sfx + 60) / 60 * 100
	animate_healthbar(sfx_bar, end)

func animate_healthbar(bar, end):
	tween.interpolate_property(bar, "value", bar.value, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_MainVolUp_pressed():
	DataResource.change_audio_master(6)

func _on_MainVolDown_pressed():
	print(202)
	DataResource.change_audio_master(-6)

func _on_MusicVolUp_pressed():
	DataResource.change_audio_music(6)

func _on_MusicVolDown_pressed():
	print(101)
	DataResource.change_audio_music(-6)

func _on_SFXVolUp_pressed():
	DataResource.change_audio_sfx(6)

func _on_SFXVolDown_pressed():
	DataResource.change_audio_sfx(-6)

#change this to go back to previously loaded scene
func _on_Back_pressed():
	SceneControl.button_click.play()
	change_active_tab(base_empty)
	slider.hide()
	slider_active = false
	DataResource.save_rest() # so that the new settings persist on next save file
	SceneControl.settings_layer.hide()
	emit_signal("closed_settings")

func handle_input(event):
	if Input.is_action_just_pressed("escape"):
		_on_Back_pressed()

func _on_Controls_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, controls.rect_position.y)
	var new_offset = controls.get_child(0).rect_size.y /4
	slide_to_position(new_position, new_offset)

func _on_Audio_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, audio.rect_position.y)
	var new_offset = audio.get_child(0).rect_size.y /4
	slide_to_position(new_position, new_offset)

func _on_Game_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, game.rect_position.y)
	var new_offset = game.get_child(0).rect_size.y /4
	slide_to_position(new_position, new_offset)


func _on_Back_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, back.rect_position.y)
	var new_offset = back.get_child(0).rect_size.y /4
	slide_to_position(new_position, new_offset)

# Slides the slider to the intended position, or shows it there if not visible
func slide_to_position(new_position, new_offset):
	# Offset of position
	new_position.y += contents.rect_position.y
	new_position.y /= 6.25
	new_position.y += new_offset
	var old_position = slider.rect_position
	if(slider_active):
		tween.interpolate_property(slider, "rect_position", old_position, new_position, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
	else:
		slider.rect_position.y = new_position.y
		slider.show()
		slider_active = true

func _on_Controls_pressed():
	SceneControl.button_click.play()
	change_active_tab(base_controls)

func _on_Audio_pressed():
	SceneControl.button_click.play()
	change_active_tab(base_audio)

func _on_Game_pressed():
	SceneControl.button_click.play()
	change_active_tab(base_game)

func change_active_tab(new_tab):
	if(active_tab):
		active_tab.hide()

	active_tab = new_tab
	active_tab.show()
