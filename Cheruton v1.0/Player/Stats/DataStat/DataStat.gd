extends Control


const FILLER = "          "

onready var bar = $Bar
onready var tween = $Tween
onready var parent_value = get_parent().get_node("Value")
onready var parent_rating_value = get_parent().get_node("ValueRating")
#onready var bar_type = get_parent().name

func init_bar(type_name):
	var item = DataResource.temp_dict_player[type_name]
	bar.value = item
	parent_value.text = str(item)
	parent_rating_value.text = FILLER
	

func change_bar_value(value, browse := false, fix := false):
	change_bar_colour(value, browse, fix)
	animate_bar(bar.value, value)


func change_bar_colour(value, browse, fix):
	if(!browse):
		bar.set_tint_progress(Color(1, 1, 1))   # White
		if(fix):
			if(value == bar.value):
				parent_value.text = str(value)
			else:
				parent_rating_value.hide()
				animate_bar(bar.value, value)
				parent_value.text = str(value)

		parent_rating_value.text = FILLER
		parent_rating_value.show()

	else:
		if(value > bar.value || !DataResource.temp_dict_player[get_tree().current_scene.active_tab.name + "_item"]):
			bar.set_tint_progress(Color(0, 1, 0))   # Green
			parent_rating_value.set("custom_colors/font_color",Color(0, 1, 0))
		elif(value < bar.value):
			bar.set_tint_progress(Color(1, 0, 0))   # Red
			parent_rating_value.set("custom_colors/font_color", Color(1, 0, 0))
		parent_rating_value.text = ""

func animate_bar(start, end):
	tween.interpolate_property(bar, "value", start, end, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_Bar_value_changed(value):
	if(parent_rating_value.text != FILLER || !parent_rating_value.is_visible()):
		parent_rating_value.text = ">> " + str(value)
