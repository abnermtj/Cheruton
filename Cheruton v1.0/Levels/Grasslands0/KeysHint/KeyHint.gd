extends Node2D

export var action_name : String = "jump" # Key derived from input map

onready var base = $Base
onready var non_text_key_sprite = $Base/NonTextKey
onready var key_label = $Base/Key

func _process(delta):
	var input_event

	key_label.rect_size = Vector2(8, 10) # default size for a single key
	base.rect_size = Vector2(16, 16)
	if action_name:
		input_event = InputMap.get_action_list(action_name)[0]

	if input_event is InputEventMouseButton:
		var button_idx = input_event.button_index

		match button_idx:
			BUTTON_LEFT:
				non_text_key_sprite.texture = load ("res://Levels/Grasslands0/KeysHint/Sprites/LeftClick.png")
			BUTTON_RIGHT:
				non_text_key_sprite.texture = load ("res://Levels/Grasslands0/KeysHint/Sprites/RightClick.png")

		key_label.hide()
		non_text_key_sprite.show()

	else: # Is Key on keyboard
		key_label.text = input_event.as_text()

		# Resize base to fit text size
		var string_size = key_label.get_font("normal_font").get_string_size(key_label.text)

		key_label.rect_size = string_size
		base.rect_size = string_size + Vector2(9, 0)
		key_label.show()
		non_text_key_sprite.hide()
