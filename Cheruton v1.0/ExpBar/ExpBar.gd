extends Control

var old_level

func _ready():
	# change loaded to when start game
	DataResource.connect("loaded", self, "initbar")
	DataFunctions.connect("update_exp", self, "update_expbar")



func initbar():
	var old_exp = DataResource.dict_player["exp_curr"]
	var old_exp_max = DataResource.dict_player["exp_max"]
	old_level = DataResource.dict_player["level"]
	if(old_exp_max != 0):
		$ExpBar.value = old_exp/old_exp_max * 100

func update_expbar(new_exp, new_exp_max, new_level):
	
	while(old_level < new_level):
		animate_expbar($ExpBar.value, 100)
		yield(get_tree().create_timer(0.2), "timeout")
		$ExpBar.value = 0
		old_level+=1
		
	animate_expbar($ExpBar.value, new_exp/new_exp_max * 100)

func animate_expbar(start, end):
	$Tween.interpolate_property($ExpBar, "value", start, end, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	
