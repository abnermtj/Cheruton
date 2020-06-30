extends Node

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"

onready var timer = $Timer
onready var encryption = $Encryption
onready var arrow = preload("res://Display/MouseDesign/arrow.png")
onready var beam = preload("res://Display/MouseDesign/beam.png")
var count := 0

func _ready():
	var error = DataResource.load_data(OS.get_unique_id())
#	if(!error):
#		timer.stop()
#		encryption.show()
#		return
	init_music()
	#init_cursor()



func _on_Timer_timeout():
	SceneControl.load_screen(MAINMENU)
	self.queue_free()

func init_music():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), DataResource.dict_settings.is_mute)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), DataResource.dict_settings.audio_master)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), DataResource.dict_settings.audio_music)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), DataResource.dict_settings.audio_sfx)


func init_cursor():
	Input.set_custom_mouse_cursor(arrow)
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)


func _on_LineEdit_text_entered(new_text):
	while (count < 3):
		var error_code = DataResource.load_data(new_text)
		if(!error_code):
			_on_Timer_timeout()
			return
		count += 1
	if (count == 3):
		get_tree().quit()

	pass
