extends Node

enum sweep_states {ANTICIPATION = 0, SWEEP = 1, RETURN = 3}
var cur_state
func enter():
	cur_state = sweep_states.ANTICIPATION

func update():
	match cur_state:
		sweep_states.ANTICIPATION:
			pass
		sweep_states.SWEEP:
			pass
		sweep_states.RETURN:
			pass
