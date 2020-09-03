extends Node
class_name baseState

signal changeState(next_state_name)

# Initialize the state. E.g. change the animation
func enter():
	return

# Clean up the state. Reinitialize values like a timer
func exit():
	return

func handle_input(event):
	return

func update(delta):
	return

func update_idle(delta):
	return

func _on_animation_finished(anim_name):
	return
