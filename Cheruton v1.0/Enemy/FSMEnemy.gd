extends Node
class_name FSM_Enemy

var debug = false
var states = {}
var state_curr = null
var state_next = null
var state_prev = null
var object = null


func _init(input_object, initial_state, self_debug = false ):
	self.object = input_object
	#self.debug = self_debug
	_set_states_parent_node(initial_state.get_parent())
	state_next = initial_state


func _set_states_parent_node(p_node):
	#if debug: print( "Found ", p_node.get_child_count(), " states" )
	if p_node.get_child_count() > 0:
		var state_nodes = p_node.get_children()
		for state_node in state_nodes:
			if debug: print( "adding state: ", state_node.name)
			states[state_node.name] = state_node
			state_node.fsm = self
			state_node.obj = self.object


func run_machine(delta):

	if(!state_next && !state_curr):
		return

	if(state_next != state_curr):
		# Terminate current state if it is still running
		if(state_curr):
			#if debug:
				#print( object.name, ": changing from state ", state_curr.name, " to ", state_next.name )
			state_curr.terminate()
		#elif debug:
			#print( object.name, ": starting with state ", state_next.name )
		# Assign the next state and initiaize it
		state_prev = state_curr
		state_curr = state_next
		if(state_curr):
			state_curr.initialize()
	# run state
	if(state_curr):
		state_curr.run(delta)
		if(states.has("Fall") && state_curr != states.Dead):
			state_curr.should_fall()

