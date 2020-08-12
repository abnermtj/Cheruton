extends Control

const LMB = "InputEventMouseButton : button_index=BUTTON_LEFT, pressed=false, position=(0, 0), button_mask=0, doubleclick=false"
const RMB = "InputEventMouseButton : button_index=BUTTON_RIGHT, pressed=false, position=(0, 0), button_mask=0, doubleclick=false"
const UNASSIGN = "Unassigned"

const RED = Color(1,0,0,1)
const WHITE = Color(1,1,1,1)

onready var control_label = preload("res://Display/Settings/control_label.tscn")
onready var control_btn = preload("res://Display/Settings/control_btn.tscn")

onready var master_bar = $Settings/Container/Main/Contents/BaseAudio/Rect/Contents/SoundBar/MainVolBar
onready var music_bar = $Settings/Container/Main/Contents/BaseAudio/Rect/Contents/SoundBar/MusicVolBar
onready var sfx_bar = $Settings/Container/Main/Contents/BaseAudio/Rect/Contents/SoundBar/SFXVolBar


onready var container = $Settings/Container
onready var contents = $Settings/Container/Main/Contents
onready var controls_column = $Settings/Container/Main/Contents/BaseControls/Scroll

onready var slider = $Settings/Slider
onready var tween = $Tween
onready var controls = $Settings/Container/Main/Contents/Options/Controls
onready var audio = $Settings/Container/Main/Contents/Options/Audio
onready var game = $Settings/Container/Main/Contents/Options/Game
onready var back = $Settings/Container/Main/Contents/Options/Back


onready var controls_action = $Settings/Container/Main/Contents/BaseControls/Scroll/Column/Action
onready var controls_mapping = $Settings/Container/Main/Contents/BaseControls/Scroll/Column/Mapping
onready var controls_message = $Settings/Container/Main/Contents/BaseControls/Message
onready var controls_reset = $Settings/Container/Main/Contents/BaseControls/Button

onready var base_controls = $Settings/Container/Main/Contents/BaseControls
onready var base_audio = $Settings/Container/Main/Contents/BaseAudio
onready var base_game = $Settings/Container/Main/Contents/BaseGame
onready var base_empty = $Settings/Container/Main/Contents/BaseEmpty


var slider_active := false
var edit_control := false
var prior_collision := false

var temp_control
var key_action := []
var key_duplicates := {}

onready var active_tab = base_empty

signal closed_settings

func _ready():
	init_key_bindings()
	init_bar_vals()
	connect_functions()

############
# CONTROLS #
############

# Updates configurable keys in the controls displays
func init_key_bindings(reset:= false):
	key_action = InputMap.get_actions()
	key_action.sort()
	var action_size = key_action.size()
	
	for i in action_size:
		if(key_action[i].find("ui") != -1):
			continue
		var new_label
		var new_button
		var x = key_action[i]
		match reset:
			true:
				new_button = controls_mapping.get_node(key_action[i])
			false:
				new_label = control_label.instance()
				new_button = control_btn.instance()
				
				new_label.name = key_action[i]
				new_button.name = key_action[i]
				new_button.get_child(0).name = key_action[i]
			
				new_label.text = key_action[i].capitalize()
				new_button.connect("pressed" ,self, "_on_button_pressed", [new_button])
				new_button.connect("mouse_entered" ,self, "_on_button_mouse_entered", [new_button])
				controls_action.add_child(new_label)
				controls_mapping.add_child(new_button) 
			
		new_button.get_child(0).text = reform_btn_text(InputMap.get_action_list(key_action[i])[0].as_text())
		if(new_button.get_child(0).get("custom_colors/font_color") == RED):
			new_button.get_child(0).set("custom_colors/font_color", WHITE)
		
		
func reform_btn_text(text):
	match text:
		LMB:
			return "Left Mouse"
		RMB:
			return "Right Mouse"

	return text

# Reformats certain keypress nodes
func check_mouse_text(btn_text):
	if(btn_text == RMB):
		return "Right Mouse"
	elif(btn_text == LMB):
		return "Left Mouse"
	return btn_text

# when the button is pressed
func _on_button_pressed(button):
	edit_control = false
	
	if(temp_control):
		if(prior_collision):
			temp_control.get_child(0).set("custom_colors/font_color", RED)
		temp_control.get_child(0).text = reform_btn_text(InputMap.get_action_list(temp_control.name)[0].as_text())
	
	if(button.get_child(0).get("custom_colors/font_color") == RED):
		button.get_child(0).set("custom_colors/font_color", WHITE)
		prior_collision = true
	else:
		prior_collision = false
	
	button.get_child(0).text = UNASSIGN
	temp_control = button
	edit_control = true

func _on_button_mouse_entered(button):
	if(temp_control != button):
		edit_control = false

func _input(event):
	# Keyboard Button
	if event is InputEventKey:
		if(edit_control):
			edit_control = false
			_edit_key(event)

	# Mouse Button
	elif event is InputEventMouseButton:
		if(edit_control):
			edit_control = false
			if(event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT):
				align_mouse_event(event)
				_edit_key(event)

# Affixes the standard mouse button properties to the pressed button
func align_mouse_event(event):
	event.position = Vector2(0, 0)
	event.button_mask= 0
	event.pressed = false
	event.doubleclick = false

# Affixes the new key binding to the action highlighted
func _edit_key(new_key):
	var action_name = temp_control.name
	var old_key
	if !InputMap.get_action_list(action_name).empty():
		old_key = InputMap.get_action_list(temp_control.name)[0]
		InputMap.action_erase_event(action_name, InputMap.get_action_list(action_name)[0])

	check_duplicates(new_key, temp_control.name)
	# Update duplicate list
	InputMap.action_add_event(action_name, new_key)

	var btn_text = reform_btn_text(InputMap.get_action_list(temp_control.name)[0].as_text())
	DataResource.dict_input_map[temp_control.name] = btn_text
	temp_control.get_child(0).text = btn_text
	
	temp_control = null

# Detects actions who  occupy the same key binding as the new key2
func check_duplicates(new_key, action_assigned):

	var action_size = key_action.size()
	for i in action_size:
		if(key_action[i].find("ui") != -1):
			continue
		var check = InputMap.event_is_action(new_key, key_action[i])
		
		# Duplicate has been detected
		if(check):
			handle_duplicates(action_assigned, key_action[i])
			controls_message.show()
			controls_reset.show()
			back.disabled = true
			return
		
		#Update duplicate list if it was previously a duplicate
		if(prior_collision):
			clear_duplicates(action_assigned)

# Handles actions with the same key_bindings
func handle_duplicates(action_assigned, conflicting_action):
	var duplicate_size = key_duplicates.size()
	var inserted = false
	
	if(duplicate_size != 0):
		for i in duplicate_size:
			# Case 1: Array does not contain either actions
			if(!(key_duplicates[i].has(action_assigned) ||key_duplicates[i].has(conflicting_action))):
				continue
			# Case 2: Array contains the action causing the conflict
			elif(key_duplicates[i].has(action_assigned) && !key_duplicates[i].has(conflicting_action)):
				key_duplicates[i].erase(action_assigned)
			# Case 3: Array contains the action that conflicted with the assigned action
			elif(!key_duplicates[i].has(action_assigned) && key_duplicates[i].has(conflicting_action)):
				key_duplicates[i].append(action_assigned)
				inserted = true
	# Inserts new array of conflicts
	if(!inserted):
		key_duplicates[duplicate_size] = []
		key_duplicates[duplicate_size].append(action_assigned)
		key_duplicates[duplicate_size].append(conflicting_action)
	
	var assigned_mapping = controls_mapping.get_node(action_assigned).get_child(0) 
	var conflict_mapping = controls_mapping.get_node(conflicting_action).get_child(0)
	
	assigned_mapping.set("custom_colors/font_color", RED)
	conflict_mapping.set("custom_colors/font_color", RED)

# Clears duplicates that have been resolved
func clear_duplicates(action_assigned):
	var duplicate_size = key_duplicates.size()

	for i in duplicate_size:
		if(key_duplicates[i].has(action_assigned)):
			key_duplicates[i].erase(action_assigned)
			
			if(key_duplicates[i].size() == 1):
				var conflict_mapping = controls_mapping.get_node(key_duplicates[i][0]).get_child(0)
				conflict_mapping.set("custom_colors/font_color", WHITE)
				key_duplicates.erase(i)
			break

	var assigned_mapping = controls_mapping.get_node(action_assigned).get_child(0)
	assigned_mapping.set("custom_colors/font_color", WHITE)
	
	if(key_duplicates.empty()):
		controls_message.hide()
		back.disabled = false


func _on_Reset_pressed():
	handle_reset()
	controls_message.hide()
	controls_reset.hide()
	back.disabled = false

func handle_reset():
	key_duplicates.clear()
	InputMap.load_from_globals()
	init_key_bindings(true)

#########
# AUDIO #
#########

func init_bar_vals():
	master_bar.value = (DataResource.dict_settings.audio_master + 60) / 60 * 100
	music_bar.value = (DataResource.dict_settings.audio_music + 60) / 60 * 100
	sfx_bar.value = (DataResource.dict_settings.audio_sfx + 60) / 60 * 100

func connect_functions():
	var _conn1 = DataResource.connect("change_audio_master", self, "change_master_vol")
	var _conn2 = DataResource.connect("change_audio_music", self, "change_music_vol")
	var _conn3 = DataResource.connect("change_audio_sfx", self, "change_sfx_vol")

func _on_MuteToggle_pressed():
	DataResource.dict_settings.is_mute = !DataResource.dict_settings.is_mute
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), DataResource.dict_settings.is_mute)

func change_master_vol():
	SceneControl.button_click.play()
	var end = (DataResource.dict_settings.audio_master + 68) / 60 * 100
	animate_healthbar(master_bar, end)

func change_music_vol():
	SceneControl.button_click.play()
	var end = (DataResource.dict_settings.audio_music + 68) / 60 * 100
	animate_healthbar(music_bar, end)

func change_sfx_vol():
	SceneControl.button_click.play()
	var end = (DataResource.dict_settings.audio_sfx + 68) / 60 * 100
	animate_healthbar(sfx_bar, end)

func animate_healthbar(bar, end):
	SceneControl.button_click.play()
	tween.interpolate_property(bar, "value", bar.value, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_MainVolUp_pressed():
	SceneControl.button_click.play()
	DataResource.change_audio_master(6)

func _on_MainVolDown_pressed():
	SceneControl.button_click.play()
	DataResource.change_audio_master(-6)

func _on_MusicVolUp_pressed():
	SceneControl.button_click.play()
	DataResource.change_audio_music(6)

func _on_MusicVolDown_pressed():
	SceneControl.button_click.play()
	DataResource.change_audio_music(-6)

func _on_SFXVolUp_pressed():
	SceneControl.button_click.play()
	DataResource.change_audio_sfx(6)

func _on_SFXVolDown_pressed():
	SceneControl.button_click.play()
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
	pass
#	var new_position = Vector2(slider.rect_position.x, game.rect_position.y)
#	var new_offset = game.get_child(0).rect_size.y /4
#	slide_to_position(new_position, new_offset)


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
	pass
#	SceneControl.button_click.play()
#	change_active_tab(base_game)

func change_active_tab(new_tab):
	if(active_tab):
		active_tab.hide()

	active_tab = new_tab
	active_tab.show()





