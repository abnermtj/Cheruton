extends Node2D

var count = 0
var original_head_pos
#var original_robe_pos
#var original_hand_pos 
#var original_footwear_pos 
const HEAD_POS = Vector2(204,22)
const ROBE_POS = Vector2(204,52)
const HAND_POS = Vector2(204,82)
const FOOTWEAR_POS = Vector2(204,112)

func _ready():
	DataResource.dict_settings["game_on"] = false
	$Coin/CoinValue.text = str(DataResource.dict_player["coins"])
	original_head_pos = HEAD_POS


func _on_Exit_pressed():
	free_the_inventory()

func free_the_inventory():
	DataResource.dict_settings["game_on"] = true
	var scene_to_free = DataResource.current_scene.get_child(DataResource.current_scene.get_child_count() - 1)
	scene_to_free.queue_free()



func _on_Test_pressed(): # creates a double click signal and activates tooltips
	count += 1
	tooltips($Test.texture_normal)
	if (count == 2):
		equip_dequip($Test)
		$Tooltips/CurrItem.set_texture(null)
		count = 0
		
func equip_dequip(node):

		var update_pos = node.rect_position
		node.rect_position = original_head_pos
		original_head_pos = update_pos


func tooltips(texture):
	$Tooltips/CurrItem.set_texture(texture)


func _on_Test2_pressed():
	count += 1
	tooltips($Test2.texture_normal)
	if (count == 2):
		equip_dequip($Test2)
		$Tooltips/CurrItem.set_texture(null)
		count = 0
