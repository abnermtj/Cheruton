extends Control


func _ready():
	DataResource.dict_settings["game_on"] = true
	$StatsRect/ExpBar.initbar()
	$StatsRect/HealthBar.initbar()
