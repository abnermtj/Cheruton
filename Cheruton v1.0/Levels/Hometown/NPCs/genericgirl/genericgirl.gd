extends MovingNPC

func _ready():
	._ready()
	walk_speed = 110
	DIR_CHANGE_TIME = 2.5
	dir = 1
