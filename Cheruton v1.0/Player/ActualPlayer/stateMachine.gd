extends Node
class_name baseFSM
signal state_changed(current_state)

"""
from GDquest Godot demos
You must set a starting node from the inspector or crash
"""

export(NodePath) var START_STATE
var states_map = {}

var states_stack = []
var current_state = null
var previous_state = null # for function

var _active = false setget set_active

func _ready(): # ready function not overwritten so no need ._ready() in inheritors
	for child in get_children():
		states_map[child.name] = child

	for child in get_children():
		child.connect("finished", self, "_change_state")
	set_active(true)
	set_start_state(START_STATE)

func set_active(value):
	_active = value
	set_physics_process(value)
	set_process(value)
	set_process_input(value)

	if not _active:
		states_stack = []
		current_state = null
	else:
		set_start_state(START_STATE)

func set_start_state(start_state):
	states_stack.resize(0)
	states_stack.push_front(get_node(start_state))
	current_state = states_stack[0]
	current_state.enter()

func _input(event):
	current_state.handle_input(event)

func _physics_process(delta):
	current_state.call_deferred("update", delta)

func _process(delta):
	current_state.call_deferred("update_idle", delta)

func _on_animation_finished(anim_name):
	if not _active:
		return
	current_state._on_animation_finished(anim_name)

#func _change_state(state_name):
#	if not _active:
#		return
#	current_state.exit()
#
#	states_stack[0] = states_map[state_name]
#
#	current_state = states_stack[0]
#	emit_signal("state_changed", states_stack)
#
#	current_state.enter()

func _change_state(state_name):
	if not _active:
		return
	current_state.call_deferred("exit")

	states_stack[0] = states_map[state_name]

	current_state = states_stack[0]
	emit_signal("state_changed", states_stack)

	current_state.call_deferred("enter")
