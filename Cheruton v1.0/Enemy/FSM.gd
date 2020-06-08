extends Node
class_name FSM_Enemy

var debug = false
var states = {}
var state_curr = null
var state_next = null
var state_prev = null
var object = null

# Initializes the current state of the character
func _init(object, state_parent, initial_state, debug_case = false ):
	self.obj = object
	self.debug = debug_case
	_set_state_parent(state_parent)
	state_next = initial_state

# Sets the parent node of the current state
func _set_state_parent(parent_node):
	if(debug):
		print( "True", parent_node.get_child_count(), " states" )
	if parent_node.get_child_count() == 0:
		return
	var state_nodes = parent_node.get_children()
	for state_node in state_nodes:
		if(debug): 
			print( "adding state: ", state_node.name)
		states[state_node.name] = state_node
		state_node.fsm = self
		state_node.obj = self.obj

# Runs the FSM, changing the state when required
func run_fsm(delta):
	if (state_next != state_curr):
		if (state_curr):
			if debug:
				print( object.name, ": changing from state ", state_curr.name, " to ", state_next.name )
			state_curr.terminate()
		elif debug:
			print(object.name, ": starting with state ", state_next.name )
		state_prev = state_curr
		state_curr = state_next
		state_curr.initialize()
	# run the new state
	state_curr.run(delta)

