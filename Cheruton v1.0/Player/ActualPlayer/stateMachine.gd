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
var _active = false setget set_active

func _ready():
	for child in get_children():
		child.connect("finished", self, "_change_state")
	initialize(START_STATE)

func initialize(start_state):
	set_active(true)
	states_stack.push_front(get_node(start_state))
	current_state = states_stack[0]
	current_state.enter()

func set_active(value):
	_active = value
	set_physics_process(value)
	set_process_input(value)
	if not _active:
		states_stack = []
		current_state = null

func _input(event):
	current_state.handle_input(event)

func _physics_process(delta):
	current_state.update(delta)

func _on_animation_finished(anim_name):
	if not _active:
		return
	current_state._on_animation_finished(anim_name)

func _change_state(state_name):
	if not _active:
		return
	current_state.exit()

	if state_name == "previous": # pop the current one to goto the new one
		states_stack.pop_front()
	else:
		states_stack[0] = states_map[state_name]

	current_state = states_stack[0]
	emit_signal("state_changed", states_stack)

	#if state_name != "previous": # didn't see the need for this treat previous entry as if just entered
	current_state.enter()
