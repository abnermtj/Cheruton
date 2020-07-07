extends basePopUp

const TIME_PER_CHAR_WRITE = .024 # seconds

onready var dialogue_base = $dialogBox/bodyBackground
onready var dialogue_text = $dialogBox/bodyBackground/MarginContainer/bodyText
onready var tween = $dialogBox/bodyBackground/Tween

var dialog : String
var finished_current_node : bool
var finished_last_node

var dialog_id = 0
var node_id = 0
var final_node_id = 0
var story_reader

func _ready():
	var story_reader_class = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
	story_reader = story_reader_class.new()

	load_story("res://Levels/Hometown/Stories/Baked/HometownDialog.tres")

func begin():
	tween.interpolate_property(dialogue_base, "rect_scale", Vector2(0.1,1), Vector2(1,1), 0.26,Tween.TRANS_BACK, Tween.EASE_OUT, 0)
	tween.start()
	show()

func load_story(path : String): # LOAD OLLECTION OF ALL DIALOGS IN THAT MAP
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
			if not finished_last_node:
				play_dialog()
		elif not finished_current_node:
			tween.stop(dialogue_text, "percent_visible")
			dialogue_text.percent_visible = 1
			finished_current_node = true

func _process(delta):
	if is_active_gui:
		dialogue_base.rect_pivot_offset = dialogue_base.rect_size/2 # doing this will allow the base to be scaled from the center

func get_next_node():
	node_id = story_reader.get_nid_from_slot(dialog_id, node_id, 0)

	if node_id == final_node_id:
		finished_last_node = true
		end_conversation()

func play_dialog():
	finished_current_node = false

	var text = story_reader.get_text(dialog_id, node_id)
	var dialog = _get_tagged_text("dialog", text)

	dialogue_text.bbcode_text = dialog

	dialogue_text.percent_visible = .01 # intentional start never empty
	tween.interpolate_property(dialogue_text, "percent_visible", .01, 1, TIME_PER_CHAR_WRITE * dialog.length(),  Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	tween.start()

func _on_Tween_tween_completed(object, key):
	if key == ":percent_visible":
		finished_current_node = true
	elif key == ":rect_scale" and not is_active_gui:
		hide()

func _get_tagged_text(tag : String, text : String):
	var start_tag = "<" + tag + ">"
	var end_tag = "</" + tag + ">"
	var start_index = text.find(start_tag) + start_tag.length() # finding indexes  between the <> delimiters
	var end_index = text.find(end_tag) # end tag is at '<'
	var substr_length = end_index - start_index # sub string length

	return text.substr(start_index, substr_length)

func end_conversation():
	DataResource.temp_dict_player.dialog_complete = true

	tween.interpolate_property(dialogue_base, "rect_scale", Vector2(1,1), Vector2(.1,1), 0.2,Tween.TRANS_BACK, Tween.EASE_IN, 0)
	tween.start()
	DataResource.save_rest()
	emit_signal("release_gui", "dialog")

func end(): # inherited method is will hide prematurely
	pass
