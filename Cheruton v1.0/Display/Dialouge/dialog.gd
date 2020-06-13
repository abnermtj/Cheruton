extends baseGui

const TIME_PER_CHAR_WRITE = .03 # in seconds .03 is good

onready var dialogue_text = $dialogBox/body_background/MarginContainer/body_text
onready var speaker_text = $dialogBox/speaker_background/MarginContainer/speaker_name
onready var next_indicator = $dialogBox/body_background/MarginContainer/next_indicator
onready var tween = $dialogBox/body_background/MarginContainer/Tween

var dialog : String
var finished_current_node : bool
var finished_last_node : bool

var dialog_id = 0
var node_id = 0
var final_node_id = 0
var story_reader

func _ready():
	var story_reader_class = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
	story_reader = story_reader_class.new()

	var story = load("res://Stories/Baked/HometownDialog.tres")
	story_reader.read(story)

	start_dialog("Hometown/Moneygirl")
	next_indicator.visible = false

func start_dialog(record_name : String): # THIS IS THE FUNCTION TO CALL FROM OUTSIDE SCENES
	finished_current_node = false
	finished_last_node = false

	dialog_id = story_reader.get_did_via_record_name(record_name)
	node_id = self.story_reader.get_nid_via_exact_text(dialog_id, "<start>")
	final_node_id = story_reader.get_nid_via_exact_text(dialog_id, "<end>")
	get_next_node()
	play_dialog()
	show()

func handle_input(event): # change name to handle_input when under level gui master
	if Input.is_action_just_pressed("jump"):
		if finished_current_node and not finished_last_node:
			get_next_node()
			if not finished_last_node:
				play_dialog()
		elif not finished_current_node:
			tween.stop_all()
			dialogue_text.percent_visible = 1
			finished_current_node = true

func get_next_node():
	node_id = story_reader.get_nid_from_slot(dialog_id, node_id, 0) # this is represented as the output of each node in a story

	if node_id == final_node_id:
		finished_last_node = true
		release_gui()

func play_dialog():
	finished_current_node = false

	var text = story_reader.get_text(dialog_id, node_id)
	var speaker = _get_tagged_text("speaker", text)
	var dialog = _get_tagged_text("dialog", text)

	speaker_text.bbcode_text = speaker
	dialogue_text.bbcode_text = dialog

	dialogue_text.percent_visible = .01 # start never empty
	tween.interpolate_property(dialogue_text, "percent_visible", .01, 1, TIME_PER_CHAR_WRITE * dialog.length(),  Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	tween.start()

func _get_tagged_text(tag : String, text : String):
	var start_tag = "<" + tag + ">"
	var end_tag = "</" + tag + ">"
	var start_index = text.find(start_tag) + start_tag.length() # finding indexes  between the <> delimiters
	var end_index = text.find(end_tag) # end tag is at '<'
	var substr_length = end_index - start_index # sub string length

	return text.substr(start_index, substr_length)

func _on_Tween_tween_completed(object, key):
	finished_current_node = true

func _process(delta):
	next_indicator.visible = finished_current_node

func release_gui():
	DataResource.save_rest()
	emit_signal("release_gui", "dialog")
