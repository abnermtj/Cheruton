extends baseFSM

func _ready():
	states_map = {
		"idle": $idle,
		"run": $run
	}
