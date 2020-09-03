extends Node
class_name baseFSM
signal stateChanged(curState)

export(NodePath) var START_STATE
var statesDict = {}

var statesStack = []
var curState = null
var prevState = null

var isInputEnabled = false # Thus must be manualy set true in input controlled subclasses
var isActive = false setget setFsmActive

# _ready() function not overridable so no need ._ready() in subclasses
# This function
func _ready():
	setFsmActive(true)
	initializeStates()
	setStartStateAndEnter(START_STATE)

func initializeStates():
	for child in get_children():
			statesDict[child.name] = child
			child.connect("changeState", self, "onChangeState")

func setStartStateAndEnter(startState):
	statesStack.resize(0) # in case you reset to start mid game
	statesStack.push_front(get_node(startState))

	curState = statesStack[0]
	curState.call_deferred("enter")

func setFsmActive(value):
	isActive = value
	set_physics_process(value)
	set_process(value)
	set_process_input(value)
#
#	if isActive:
#		setStartStateAndEnter(START_STATE)
#	else:
#		statesStack = []
#		curState = null


func _input(event):
	if isInputEnabled:
		curState.handle_input(event)

func _physics_process(delta):
	curState.call_deferred("update", delta)

func _process(delta):
	curState.call_deferred("update_idle", delta)

func _on_animation_finished(anim_name):
	if not isActive:
		return
	curState._on_animation_finished(anim_name)

func onChangeState(state_name):
	if not isActive:
		return
	curState.call_deferred("exit")

	statesStack[0] = statesDict[state_name]

	curState = statesStack[0]
	emit_signal("stateChanged", statesStack)

	curState.call_deferred("enter")
