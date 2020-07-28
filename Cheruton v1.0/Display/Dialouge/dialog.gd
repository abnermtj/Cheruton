extends basePopUp

var TIME_PER_CHAR_WRITE = .014 # seconds

onready var dialogue_base = $dialogBox/bodyBackground
onready var dialogue_text = $dialogBox/bodyBackground/MarginContainer/bodyText
onready var tween = $dialogBox/bodyBackground/Tween
onready var audio = $AudioStreamPlayer

var dialog : String
var dialog_left : String
var finished_current_node : bool
var finished_last_node

var dialog_id = 0
var node_id = 0
var final_node_id = 0
var story_reader

func _ready():
	var story_reader_class = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
	story_reader = story_reader_class.new()

	load_story("res://Levels/Grasslands2/Stories/Baked/Grasslands2Dialog.tres") # for debuging

	dialogue_base.rect_scale = Vector2(0,1)
	dialogue_text.percent_visible = 1

	$dialogBox/bodyBackground/Next.modulate.a = 0

func begin():
	tween.interpolate_property(dialogue_base, "rect_scale", Vector2(0.1,1), Vector2(1,1), .8,Tween.TRANS_BACK, Tween.EASE_OUT, 0)

	tween.start()
	show()

func load_story(path : String): # LOAD COLLECTION OF ALL DIALOGS IN THAT MAP
	var story = load(path)
	story_reader.read(story)

func start_dialog(record_name : String): # SPECIFIC DIALOG
	finished_current_node = false
	finished_last_node = false

	dialog_id = story_reader.get_did_via_record_name(record_name)
	node_id = self.story_reader.get_nid_via_exact_text(dialog_id, "<start>")
	final_node_id = story_reader.get_nid_via_exact_text(dialog_id, "<end>")

	if node_id == -1: print("start of dialog not found")
	if final_node_id == -1: print("end of dialog not found")

	get_next_node()
	play_dialog()

func handle_input(event):
	if is_active_gui and Input.is_action_just_pressed("interact"): # bcause we started via dialog visa function call vs signal, it causes the interact key used to open dialog to also skip the first text
		if finished_current_node and not finished_last_node:
			get_next_node()
			if not finished_last_node: # method above coulve changed the value
				play_dialog()
		elif not finished_current_node:
			dialogue_text.bbcode_text += dialog_left
			finished_current_node = true
			$AnimationPlayerVisibility.play("next")

func _process(delta):
	if is_active_gui:
		dialogue_base.rect_pivot_offset = dialogue_base.rect_size/2 # doing this will allow the base to be scaled from the center


func get_next_node():


	node_id = story_reader.get_nid_from_slot(dialog_id, node_id, 0)

	if node_id == final_node_id:
		finished_last_node = true
		end_conversation()

func play_dialog():
	audio.pitch_scale = rand_range(.94, .95)
	audio.play()

	finished_current_node = false
	$AnimationPlayerVisibility.play("default")

	var text = story_reader.get_text(dialog_id, node_id)
	var dialog = _get_tagged_text("dialog", text)

	dialogue_text.bbcode_text = ""
	dialog_left = dialog

	var write_speed = _get_tagged_text("speed", text)
	TIME_PER_CHAR_WRITE = float(write_speed) if write_speed else .06 # .048 is fast

	start_dialog_timer()

func start_dialog_timer():
	$Timer.start(TIME_PER_CHAR_WRITE + rand_range(-.005, .005))

func _on_Timer_timeout():
	if finished_current_node : return

	var next_char = dialog_left[0]
	dialogue_text.bbcode_text += next_char
#	if not [' ',',','?','!'].has(next_char):
#		audio.pitch_scale = rand_range(.98, 1.02)
#		audio.play()

	dialog_left.erase(0, 1)
	if dialog_left == "":
		finished_current_node = true
		$AnimationPlayerVisibility.play("next")


	else:
		start_dialog_timer()

func _on_Tween_tween_completed(object, key):
	if key == ":rect_scale" and not is_active_gui:
		hide()

func _get_tagged_text(tag : String, text : String):
	var start_tag = "<" + tag + ">"
	var end_tag = "</" + tag + ">"
	var start_index = text.find(start_tag) + start_tag.length() # finding indexes  between the <> delimiters
	var end_index = text.find(end_tag) # end tag is at '<'

	if end_index == -1:
		return # not found

	var substr_length = end_index - start_index # sub string length

	return text.substr(start_index, substr_length)

func end_conversation():
	DataResource.temp_dict_player.dialog_complete = true
	
	tween.interpolate_property(dialogue_base, "rect_scale", Vector2(1,1), Vector2(.1,1), 0.2,Tween.TRANS_BACK, Tween.EASE_IN, 0)
	tween.start()
	DataResource.save_rest()
	emit_signal("release_gui", "dialog")
	
	print(is_active_gui)

func end(): # otherwise, the inherited method is will hide prematurely
	pass


