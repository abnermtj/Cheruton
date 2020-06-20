extends MovingNPC

func _ready():
	._ready()
	walk_speed = 110
	DIR_CHANGE_TIME = 4
	dir = 1
