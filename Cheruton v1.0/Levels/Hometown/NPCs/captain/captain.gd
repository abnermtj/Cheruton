extends MovingNPC

func _ready():
	._ready()
	walk_speed = 110
	dir = -1
	DIR_CHANGE_TIME = 8
	timer = DIR_CHANGE_TIME
