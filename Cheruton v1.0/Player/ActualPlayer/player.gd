extends Node2D

# all children communicate to each other via this node
# this node also helps to sync timing between two scenes

var hooked = false

func _process(delta):
	if hooked == true:
		DataResource.player_dict.player_pos = $player.global_position # updates it more regualrily



func _on_player_hook_command(com, dir, player_pos):
	$Chain.start_hook(com, dir, player_pos)


func _on_Chain_hooked(tip_pos):
	hooked = true
	$player.start_swing(tip_pos)


func _on_player_state_changed(states_stack):
	$StatesUI/Panel.change_state(states_stack)
