extends basePopUp

onready var main_bar = $Settings/Container/Main/Contents/BaseAudio/Contents/SoundBar/MainVolBar
onready var music_bar = $Settings/Container/Main/Contents/BaseAudio/Contents/SoundBar/MusicVolBar
onready var sfx_bar = $Settings/Container/Main/Contents/BaseAudio/Contents/SoundBar/SFXVolBar


onready var container = $Settings/Container
onready var contents = $Settings/Container/Main/Contents

onready var slider = $Settings/Slider
onready var tween = $Settings/Slider/Tween
onready var controls_position = $Settings/Container/Main/Contents/Options/Controls.rect_position
onready var audio_position = $Settings/Container/Main/Contents/Options/Audio.rect_position
onready var game_position = $Settings/Container/Main/Contents/Options/Game.rect_position

var slider_active := false


func _ready():
	#SceneControl.get_node("popUpGui").enabled = false
	init_bar_vals()
	connect_functions()

func init_bar_vals():
	main_bar.value = (DataResource.dict_settings.audio_master + 60) / 60 * 100
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
	main_bar.value = (DataResource.dict_settings.audio_master + 60) / 60 * 100

func change_music_vol():
	music_bar.value = (DataResource.dict_settings.audio_music + 60) / 60 * 100

func change_sfx_vol():
	sfx_bar.value = (DataResource.dict_settings.audio_sfx + 60) / 60 * 100

func _on_MainVolUp_pressed():
	DataResource.change_audio_master(6)

func _on_MainVolDown_pressed():
	DataResource.change_audio_master(-6)

func _on_MusicVolUp_pressed():
	DataResource.change_audio_music(6)

func _on_MusicVolDown_pressed():
	DataResource.change_audio_music(-6)

func _on_SFXVolUp_pressed():
	DataResource.change_audio_sfx(6)

func _on_SFXVolDown_pressed():
	DataResource.change_audio_sfx(-6)

#change this to go back to previously loaded scene
func _on_Back_pressed():
	print(true)
	DataResource.save_rest() # so that the new settings persist on next save file
	SceneControl.settings_layer.hide()
	#emit_signal("release_gui", "settings")

func handle_input(event):
	if is_active_gui and Input.is_action_just_pressed("escape"):
		_on_Back_pressed()

func _on_Controls_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, controls_position.y)
	slide_to_position(new_position)

func _on_Audio_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, audio_position.y)
	slide_to_position(new_position)

func _on_Game_mouse_entered():
	var new_position = Vector2(slider.rect_position.x, game_position.y)
	slide_to_position(new_position)

# Slides the slider to the intended position, or shows it there if not visible
func slide_to_position(new_position):
	# Offset of position
	new_position.y += container.rect_position.y + contents.rect_position.y
	var old_position = slider.rect_position
	if(slider_active):
		tween.interpolate_property(slider, "rect_position", old_position, new_position, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
	else:
		slider.rect_position.y = new_position.y
		slider.show()
		slider_active = true




